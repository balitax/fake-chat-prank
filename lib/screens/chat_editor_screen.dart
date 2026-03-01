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
  final TextEditingController _delayController = TextEditingController(
    text: '2',
  );

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
          ? _project.messages[index - 1].timestamp.add(
              const Duration(minutes: 1),
            )
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
            profile: _project.profile.copyWith(profileImagePath: image.path),
          );
        });
        _saveProject();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  void _showEditMessageDialog(MessageModel message) {
    final controller = TextEditingController(text: message.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C34) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B4A54) : const Color(0xFFE9EDEF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Edit Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 8,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Enter message...',
                prefixIcon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  _updateMessage(message.id, controller.text);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInsertMessageDialog(int index) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C34) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B4A54) : const Color(0xFFE9EDEF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Insert Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 8,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Enter message to insert...',
                prefixIcon: Icon(
                  Icons.add_comment_outlined,
                  size: 20,
                  color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    _insertMessageAt(
                      index,
                      controller.text.trim(),
                      _defaultSender,
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Insert'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(MessageModel message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C34) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B4A54) : const Color(0xFFE9EDEF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              icon: Icons.edit_outlined,
              title: 'Edit',
              onTap: () {
                Navigator.pop(context);
                _showEditMessageDialog(message);
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.add_circle_outline,
              title: 'Insert after',
              onTap: () {
                Navigator.pop(context);
                final index = _project.messages.indexOf(message) + 1;
                _showInsertMessageDialog(index);
              },
            ),
            Divider(
              color: isDark ? const Color(0xFF222D34) : const Color(0xFFE9EDEF),
              indent: 56,
            ),
            _buildOptionTile(
              context,
              icon: Icons.delete_outline,
              title: 'Delete',
              color: const Color(0xFFEA4335),
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

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: color ?? defaultColor, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? defaultColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear this chat?'),
        content: const Text(
          'All messages will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
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
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEA4335),
            ),
            child: const Text('CLEAR'),
          ),
        ],
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
    final adService = AdService();
    adService.showInterstitialAd(onComplete: () {
      if (mounted) {
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
    });
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
    final statusController = TextEditingController(
      text: _project.profile.statusText ?? '',
    );
    final lastSeenController = TextEditingController(
      text: _project.profile.lastSeenText ?? '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B4A54) : const Color(0xFFE9EDEF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Edit Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21),
                  ),
                ),
                const SizedBox(height: 20),
                // Profile image
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF6B7B8D),
                        backgroundImage:
                            _project.profile.profileImagePath != null
                            ? FileImage(
                                File(_project.profile.profileImagePath!),
                              )
                            : null,
                        child: _project.profile.profileImagePath == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white70,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await _pickProfileImage();
                            setDialogState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A884),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF1F2C34) : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                _buildModernDropdown(context, setDialogState),
                const SizedBox(height: 12),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(
                    labelText: 'Status (optional)',
                    prefixIcon: Icon(Icons.info_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lastSeenController,
                  decoration: const InputDecoration(
                    labelText: 'Last seen text (optional)',
                    prefixIcon: Icon(Icons.access_time, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _project = _project.copyWith(
                          name: nameController.text,
                          profile: _project.profile.copyWith(
                            name: nameController.text,
                            statusText: statusController.text.isEmpty
                                ? null
                                : statusController.text,
                            lastSeenText: lastSeenController.text.isEmpty
                                ? null
                                : lastSeenController.text,
                          ),
                        );
                      });
                      _saveProject();
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDropdown(
    BuildContext context,
    StateSetter setDialogState,
  ) {
    return DropdownButtonFormField<OnlineStatus>(
      value: _project.profile.onlineStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.circle, size: 12),
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
    );
  }

  void _showAutoMessageDialog() {
    _autoMessageController.clear();
    _delayController.text = '2';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2C34) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B4A54) : const Color(0xFFE9EDEF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Auto Reply',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Simulate an incoming message',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _autoMessageController,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'What should they say?',
                prefixIcon: Icon(Icons.chat_bubble_outline, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _delayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Delay (seconds)',
                prefixIcon: Icon(Icons.timer_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _startAutoMessage();
                },
                child: const Text('Start Timer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatBg = AppTheme.getChatBackground(_isDarkMode);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _project.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE9EDEF) : Colors.white,
              ),
            ),
            Text(
              '${_project.messages.length} messages',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF8696A0) : Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 22),
            onPressed: _openPreview,
            tooltip: 'Preview',
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
                case 'settings':
                  _openSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_profile',
                child: Text('Edit contact'),
              ),
              const PopupMenuItem(
                value: 'auto_message',
                child: Text('Auto reply'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat header preview
          ChatHeader(
            profile: _project.profile,
            isDarkMode: _isDarkMode,
            onEditPressed: _showEditProfileDialog,
          ),

          // Messages area
          Expanded(
            child: Container(
              color: chatBg,
              child: _project.messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessagesList(),
            ),
          ),

          // Typing + Input
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isTyping)
                Container(
                  color: chatBg,
                  child: TypingIndicator(
                    isDarkMode: _isDarkMode,
                    show: _isTyping,
                  ),
                ),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _isDarkMode
              ? const Color(0xFF182229).withValues(alpha: 0.9)
              : const Color(0xFFFFEECC).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Start the conversation by typing a message below.\nLong-press the send button to switch sender.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: _isDarkMode
                ? const Color(0xFF8696A0)
                : const Color(0xFF54656F),
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _project.messages.length,
      itemBuilder: (context, index) {
        final message = _project.messages[index];
        final showTail =
            index == _project.messages.length - 1 ||
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
}
