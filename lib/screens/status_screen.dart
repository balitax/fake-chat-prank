import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'status_view_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class StatusScreen extends StatefulWidget {
  final bool isDarkMode;
  final StorageService storageService;
  const StatusScreen({
    super.key,
    required this.isDarkMode,
    required this.storageService,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  List<StatusModel> _statuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    final savedStatuses = await widget.storageService.getStatuses();
    if (savedStatuses.isEmpty) {
      _statuses = _getInitialMockStatuses();
      await widget.storageService.saveStatuses(_statuses);
    } else {
      _statuses = savedStatuses;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<StatusModel> _getInitialMockStatuses() {
    return [
      StatusModel(
        id: 'my-status',
        contactName: 'My Status',
        isMine: true,
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        items: [
          StatusItemModel(
            id: '1',
            type: StatusType.text,
            content: 'I love this app! 😍',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            backgroundColor: '#075E54',
          ),
        ],
      ),
      StatusModel(
        id: 's1',
        contactName: 'John Doe',
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        items: [
          StatusItemModel(
            id: '2',
            type: StatusType.text,
            content: 'Hello everyone!',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            backgroundColor: '#128C7E',
          ),
        ],
      ),
    ];
  }

  Future<void> _saveStatuses() async {
    await widget.storageService.saveStatuses(_statuses);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF0B141A) : Colors.white;
    final Color sectionColor = isDark
        ? const Color(0xFF8696A0)
        : const Color(0xFF667781);

    return Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildMyStatusTile(isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Recent updates',
                    style: TextStyle(
                      color: sectionColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ..._statuses
                    .where((s) => !s.isMine)
                    .map((status) => _buildStatusTile(status, isDark)),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'status_edit',
            onPressed: _showAddTextStatusDialog,
            backgroundColor: isDark
                ? const Color(0xFF233138)
                : const Color(0xFFE9EDEF),
            child: Icon(
              Icons.edit,
              color: isDark ? const Color(0xFF8696A0) : const Color(0xFF54656F),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'status_camera',
            onPressed: _pickMediaStatus,
            backgroundColor: const Color(0xFF00A884),
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMyStatusTile(bool isDark) {
    final myStatus = _statuses.firstWhere((s) => s.isMine);
    return ListTile(
      leading: Stack(
        children: [
          _buildStatusCircle(myStatus, isDark),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00A884),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF0B141A) : Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
      title: Text(
        'My status',
        style: TextStyle(
          color: isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21),
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        'Tap to add status update',
        style: TextStyle(
          color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
          fontSize: 14,
        ),
      ),
      onTap: () => _openStatus(myStatus),
    );
  }

  Widget _buildStatusTile(StatusModel status, bool isDark) {
    return ListTile(
      leading: _buildStatusCircle(status, isDark),
      title: Text(
        status.contactName,
        style: TextStyle(
          color: isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21),
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        _formatTime(status.updatedAt),
        style: TextStyle(
          color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
          fontSize: 14,
        ),
      ),
      onTap: () => _openStatus(status),
    );
  }

  Widget _buildStatusCircle(StatusModel status, bool isDark) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00A884), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: const Color(0xFF6B7B8D),
          child: Text(
            status.contactName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _openStatus(StatusModel status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StatusViewScreen(status: status, isDarkMode: widget.isDarkMode),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return 'Yesterday';
  }

  void _showAddTextStatusDialog() {
    final controller = TextEditingController();
    String selectedColor = '#075E54';
    final colors = [
      '#075E54',
      '#128C7E',
      '#34B7F1',
      '#25D366',
      '#BD33B5',
      '#E91E63',
      '#FF9800',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Color(int.parse(selectedColor.replaceFirst('#', '0xFF'))),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.color_lens, color: Colors.white),
                  onPressed: () {
                    setDialogState(() {
                      final currentIndex = colors.indexOf(selectedColor);
                      selectedColor =
                          colors[(currentIndex + 1) % colors.length];
                    });
                  },
                ),
              ],
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Type a status',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF00A884),
              child: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  _addNewStatusItem(
                    StatusItemModel(
                      id: const Uuid().v4(),
                      type: StatusType.text,
                      content: controller.text.trim(),
                      timestamp: DateTime.now(),
                      backgroundColor: selectedColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _addNewStatusItem(StatusItemModel item) {
    setState(() {
      final myStatusIndex = _statuses.indexWhere((s) => s.isMine);
      if (myStatusIndex >= 0) {
        final List<StatusItemModel> newItems = List.from(
          _statuses[myStatusIndex].items,
        )..add(item);
        _statuses[myStatusIndex] = StatusModel(
          id: _statuses[myStatusIndex].id,
          contactName: _statuses[myStatusIndex].contactName,
          items: newItems,
          isMine: true,
          updatedAt: DateTime.now(),
        );
      }
    });
    _saveStatuses();
  }

  Future<void> _pickMediaStatus() async {
    final picker = ImagePicker();
    // Use pickMedia if available, otherwise fallback or show options
    try {
      final XFile? media = await picker.pickMedia();
      if (media != null) {
        final String path = media.path;
        final bool isVideo =
            path.toLowerCase().endsWith('.mp4') ||
            path.toLowerCase().endsWith('.mov') ||
            path.toLowerCase().endsWith('.avi');

        _addNewStatusItem(
          StatusItemModel(
            id: const Uuid().v4(),
            type: isVideo ? StatusType.video : StatusType.image,
            content: path,
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      // Fallback to image pick if pickMedia fails/not supported
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _addNewStatusItem(
          StatusItemModel(
            id: const Uuid().v4(),
            type: StatusType.image,
            content: image.path,
            timestamp: DateTime.now(),
          ),
        );
      }
    }
  }
}
