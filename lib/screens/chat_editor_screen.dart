import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../theme/app_theme.dart';
import 'chat_preview_screen.dart';
import 'settings_screen.dart';

class ChatEditorScreen extends StatefulWidget {
  final ChatProjectModel? existingProject;

  const ChatEditorScreen({super.key, this.existingProject});

  @override
  State<ChatEditorScreen> createState() => _ChatEditorScreenState();
}

class _ChatEditorScreenState extends State<ChatEditorScreen> {
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  late ChatProjectModel _project;
  bool _isDarkMode = false;
  bool _isLoading = true;
  bool _isTyping = false;
  bool _autoScroll = true;
  bool _showWatermark = true;
  
  final ScrollController _scrollController = ScrollController();
  MessageSender _defaultSender = MessageSender.me;
  Timer? _autoMessageTimer;
  final TextEditingController _autoMessageController = TextEditingController();
  final TextEditingController _delayController = TextEditingController(text: '2');

  @override
  void initState() {
    super.initState();
    _initializeProject();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isDark = await _storageService.isDarkMode();
    final settings = await _storageService.getSettings();
    setState(() {
      _isDarkMode = isDark;
      _autoScroll = settings['autoScroll'] ?? true;
      _showWatermark = settings['watermarkEnabled'] ?? true;
    });
  }

  void _initializeProject() {
    if (widget.existingProject != null) {
      _project = widget.existingProject!;
    } else {
      _project = ChatProjectModel(
        id: const Uuid().v4(),
        name: 'New Chat',
        profile: ChatProfileModel(
          id: const Uuid().v4(),
          name: 'Contact Name',
          onlineStatus: OnlineStatus.offline,
        ),
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    _isLoading = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _autoMessageTimer?.cancel();
    _autoMessageController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _addMessage(String text, MessageSender sender) {
    final message = MessageModel(
      id: const Uuid().v4(),
      text: text,
      sender: sender,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _project = _project.copyWith(
        messages: [..._project.messages, message],
        updatedAt: DateTime.now(),
      );
    });

    _saveProject();
    _scrollToBottom();
  }

  void _insertMessageAt(int index, String text, MessageSender sender) {
    final message = MessageModel(
      id: const Uuid().v4(),
      text: text,
      sender: sender,
      timestamp: _project.messages.isNotEmpty && index > 0
          ? _project.messages[index - 1].timestamp.add(const Duration(minutes: 1))
          : DateTime.now(),
      status: MessageStatus.sent,
    );

    final messages = List<MessageModel>.from(_project.messages);
    messages.insert(index, message);

    setState(() {
      _project = _project.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      );
    });

    _saveProject();
  }

  void _updateMessage(String id, String newText) {
    final messages = _project.messages.map((m) {
      if (m.id == id) {
        return m.copyWith(text: newText);
      }
      return m;
    }).toList();

    setState(() {
      _project = _project.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      );
    });

    _saveProject();
  }

  void _deleteMessage(String id) {
    final messages = _project.messages.where((m) => m.id != id).toList();

    setState(() {
      _project = _project.copyWith(
        messages: messages,
        updatedAt: DateTime.now(),
      );
    });

    _saveProject();
  }

  Future<void> _saveProject() async {
    await _storageService.saveProject(_project);
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _project = _project.copyWith(
            profile: _project.profile.copyWith(
              profileImagePath: image.path,
            ),
          );
        });
        _saveProject();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  void _showEditMessageDialog(MessageModel message) {
    final controller = TextEditingController(text: message.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Enter message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateMessage(message.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddMessageDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Enter message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addMessage(controller.text.trim(), _defaultSender);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showInsertMessageDialog(int index) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          decoration: const InputDecoration(
            hintText: 'Enter message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _insertMessageAt(index, controller.text.trim(), _defaultSender);
              }
              Navigator.pop(context);
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(MessageModel message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditMessageDialog(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Insert message after'),
              onTap: () {
                Navigator.pop(context);
                final index = _project.messages.indexOf(message) + 1;
                _showInsertMessageDialog(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startAutoMessage() {
    final message = _autoMessageController.text.trim();
    if (message.isEmpty) return;

    final delaySeconds = int.tryParse(_delayController.text) ?? 2;
    final delay = delaySeconds * 1000;

    setState(() {
      _isTyping = true;
    });

    _autoMessageTimer?.cancel();
    _autoMessageTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _addMessage(message, MessageSender.other);
      }
    });
  }

  void _openPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPreviewScreen(
          project: _project,
          isDarkMode: _isDarkMode,
          showWatermark: _showWatermark,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isDarkMode: _isDarkMode,
          onThemeChanged: (isDark) {
            setState(() {
              _isDarkMode = isDark;
            });
          },
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _project.profile.name);
    final statusController = TextEditingController(text: _project.profile.statusText ?? '');
    final lastSeenController = TextEditingController(text: _project.profile.lastSeenText ?? '');
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile image picker
                GestureDetector(
                  onTap: () async {
                    await _pickProfileImage();
                    if (mounted && context.mounted) Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: _project.profile.profileImagePath != null
                        ? FileImage(File(_project.profile.profileImagePath!))
                        : null,
                    child: _project.profile.profileImagePath == null
                        ? const Icon(Icons.add_a_photo, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<OnlineStatus>(
                  value: _project.profile.onlineStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: OnlineStatus.online, child: Text('Online')),
                    DropdownMenuItem(value: OnlineStatus.typing, child: Text('Typing')),
                    DropdownMenuItem(value: OnlineStatus.offline, child: Text('Offline')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _project = _project.copyWith(
                        profile: _project.profile.copyWith(onlineStatus: value),
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Status (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lastSeenController,
                  decoration: const InputDecoration(
                    labelText: 'Last Seen (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _project = _project.copyWith(
                    name: nameController.text,
                    profile: _project.profile.copyWith(
                      name: nameController.text,
                      statusText: statusController.text.isEmpty ? null : statusController.text,
                      lastSeenText: lastSeenController.text.isEmpty ? null : lastSeenController.text,
                    ),
                  );
                });
                _saveProject();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoMessageDialog() {
    _autoMessageController.clear();
    _delayController.text = '2';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Incoming Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _autoMessageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter automatic reply',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _delayController,
              decoration: const InputDecoration(
                labelText: 'Delay (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startAutoMessage();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _openPreview,
            tooltip: 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit_profile':
                  _showEditProfileDialog();
                  break;
                case 'auto_message':
                  _showAutoMessageDialog();
                  break;
                case 'clear':
                  _showClearDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Edit Contact'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'auto_message',
                child: ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text('Auto Reply'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep, color: Colors.red),
                  title: Text('Clear All', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Header Preview
          ChatHeader(
            profile: _project.profile,
            isDarkMode: _isDarkMode,
            onEditPressed: _showEditProfileDialog,
          ),
          // Messages List
          Expanded(
            child: Container(
              color: AppTheme.getChatBackground(_isDarkMode),
              child: _project.messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessagesList(),
            ),
          ),
          // Typing Indicator
          if (_isTyping)
            TypingIndicator(isDarkMode: _isDarkMode, show: _isTyping),
          // Input Panel
          MessageInputPanel(
            onSendMessage: _addMessage,
            defaultSender: _defaultSender,
            isDarkMode: _isDarkMode,
            onToggleSender: () {
              setState(() {
                _defaultSender = _defaultSender == MessageSender.me
                    ? MessageSender.other
                    : MessageSender.me;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMessageDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: _isDarkMode ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: _isDarkMode ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first message',
            style: TextStyle(
              fontSize: 14,
              color: _isDarkMode ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _project.messages.length,
      itemBuilder: (context, index) {
        final message = _project.messages[index];
        final showTail = index == _project.messages.length - 1 ||
            _project.messages[index + 1].sender != message.sender;

        return ChatBubble(
          message: message,
          isDarkMode: _isDarkMode,
          showTail: showTail,
          onLongPress: () => _showMessageOptions(message),
        );
      },
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Messages'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _project = _project.copyWith(
                  messages: [],
                  updatedAt: DateTime.now(),
                );
              });
              _saveProject();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
