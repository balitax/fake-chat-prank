import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../theme/app_theme.dart';

class ChatPreviewScreen extends StatefulWidget {
  final ChatProjectModel project;
  final bool isDarkMode;
  final bool showWatermark;

  const ChatPreviewScreen({
    super.key,
    required this.project,
    required this.isDarkMode,
    this.showWatermark = true,
  });

  @override
  State<ChatPreviewScreen> createState() => _ChatPreviewScreenState();
}

class _ChatPreviewScreenState extends State<ChatPreviewScreen> {
  final ScreenshotService _screenshotService = ScreenshotService();
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _chatAreaKey = GlobalKey();

  bool _isCapturing = false;
  bool _hideControls = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111B21) : Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.project.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE9EDEF) : Colors.white,
              ),
            ),
            Text(
              'Preview',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF8696A0) : Colors.white70,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_hideControls)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 22),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Edit',
            ),
          IconButton(
            icon: _isCapturing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share_outlined, size: 22),
            onPressed: _isCapturing ? null : _captureScreenshot,
            tooltip: 'Export',
          ),
          IconButton(
            icon: Icon(
              _hideControls
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _hideControls = !_hideControls;
              });
            },
            tooltip: _hideControls ? 'Show Controls' : 'Hide Controls',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RepaintBoundary(
        key: _chatAreaKey,
        child: Column(
          children: [
            ChatHeader(
              profile: widget.project.profile,
              isDarkMode: widget.isDarkMode,
              onEditPressed: () {},
              isGroupChat: widget.project.isGroupChat,
              groupMembers: widget.project.groupMembers,
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppTheme.getThemeById(
                      widget.project.chatThemeId,
                    ).chatBg(widget.isDarkMode),
                    child: widget.project.customBackgroundPath != null
                        ? Image.file(
                            File(widget.project.customBackgroundPath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  widget.project.messages.isEmpty
                      ? _buildEmptyState()
                      : _buildMessagesList(),
                ],
              ),
            ),
            if (widget.showWatermark && _hideControls)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: AppTheme.getChatBackground(widget.isDarkMode),
                child: Center(
                  child: Text(
                    'Created with Fake Chat Simulator',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.isDarkMode
                          ? const Color(0xFF8696A0).withValues(alpha: 0.4)
                          : const Color(0xFF667781).withValues(alpha: 0.3),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            if (!_hideControls) _buildInputArea(),
          ],
        ),
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
            size: 48,
            color: widget.isDarkMode
                ? const Color(0xFF8696A0).withValues(alpha: 0.3)
                : const Color(0xFF667781).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No messages',
            style: TextStyle(
              fontSize: 15,
              color: widget.isDarkMode
                  ? const Color(0xFF8696A0)
                  : const Color(0xFF667781),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: widget.project.messages.length,
      itemBuilder: (context, index) {
        final message = widget.project.messages[index];
        final showTail =
            index == widget.project.messages.length - 1 ||
            widget.project.messages[index + 1].sender != message.sender;

        final groupMember = widget.project.getMemberById(message.groupMemberId);

        return ChatBubble(
          message: message,
          isDarkMode: widget.isDarkMode,
          showTail: showTail,
          themeId: widget.project.chatThemeId,
          senderName: groupMember?.name,
          senderColor: groupMember != null
              ? Color(groupMember.colorValue)
              : null,
        );
      },
    );
  }

  Widget _buildInputArea() {
    final isDark = widget.isDarkMode;
    final iconColor = isDark
        ? const Color(0xFF8696A0)
        : const Color(0xFF667781);
    final inputBg = isDark ? const Color(0xFF2A3942) : Colors.white;
    final chatBg = isDark ? const Color(0xFF0B141A) : const Color(0xFFEFE7DE);

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
      color: chatBg,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        color: iconColor,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Message',
                          style: TextStyle(color: iconColor, fontSize: 17),
                        ),
                      ),
                    ),
                    Icon(Icons.attach_file, color: iconColor, size: 22),
                    const SizedBox(width: 12),
                    Icon(Icons.camera_alt, color: iconColor, size: 22),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF00A884),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureScreenshot() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      Uint8List? imageBytes;
      try {
        final mediaQueryData = MediaQuery.of(context);
        imageBytes = await _screenshotController.captureFromWidget(
          MediaQuery(
            data: mediaQueryData,
            child: Material(
              color: widget.isDarkMode ? Colors.black : Colors.white,
              child: Column(
                children: [
                  ChatHeader(
                    profile: widget.project.profile,
                    isDarkMode: widget.isDarkMode,
                    onEditPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      color: AppTheme.getChatBackground(widget.isDarkMode),
                      child: widget.project.messages.isEmpty
                          ? _buildEmptyState()
                          : _buildMessagesList(),
                    ),
                  ),
                  if (widget.showWatermark)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: AppTheme.getChatBackground(widget.isDarkMode),
                      child: Center(
                        child: Text(
                          'Fake Chat Simulator',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDarkMode
                                ? Colors.white24
                                : Colors.black26,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          pixelRatio: 3.0,
          delay: const Duration(milliseconds: 100),
        );
      } catch (e) {
        imageBytes = null;
      }

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      final String? savedPath = await _screenshotService.saveToGallery(
        imageBytes,
      );

      if (mounted) {
        if (savedPath != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Saved to: $savedPath')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save. Check permissions.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}
