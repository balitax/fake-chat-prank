import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode 
            ? const Color(0xFF1F2C34) 
            : const Color(0xFF128C7E),
        title: Text(widget.project.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_hideControls)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Edit',
            ),
          IconButton(
            icon: _isCapturing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.camera_alt),
            onPressed: _isCapturing ? null : _captureScreenshot,
            tooltip: 'Screenshot',
          ),
          IconButton(
            icon: Icon(_hideControls ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _hideControls = !_hideControls;
              });
            },
            tooltip: _hideControls ? 'Show Controls' : 'Hide Controls',
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _chatAreaKey,
        child: Column(
          children: [
            // Chat Header
            ChatHeader(
              profile: widget.project.profile,
              isDarkMode: widget.isDarkMode,
            ),
            // Chat Messages
            Expanded(
              child: Container(
                color: AppTheme.getChatBackground(widget.isDarkMode),
                child: widget.project.messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessagesList(),
              ),
            ),
            // Watermark (if enabled and controls are hidden)
            if (widget.showWatermark && _hideControls)
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
            // Input UI (visual only in preview)
            if (!_hideControls)
              _buildInputArea(),
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
            size: 64,
            color: widget.isDarkMode ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages',
            style: TextStyle(
              fontSize: 16,
              color: widget.isDarkMode ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.project.messages.length,
      itemBuilder: (context, index) {
        final message = widget.project.messages[index];
        final showTail = index == widget.project.messages.length - 1 ||
            widget.project.messages[index + 1].sender != message.sender;

        return ChatBubble(
          message: message,
          isDarkMode: widget.isDarkMode,
          showTail: showTail,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: widget.isDarkMode ? const Color(0xFF1F2C34) : Colors.white,
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(
              Icons.insert_emoticon,
              color: widget.isDarkMode ? Colors.white54 : Colors.black45,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.isDarkMode 
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Type a message...',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF128C7E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 20,
              ),
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
      // Capture the widget
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        Material(
          color: widget.isDarkMode ? Colors.black : Colors.white,
          child: RepaintBoundary(
            key: _chatAreaKey,
            child: Column(
              children: [
                ChatHeader(
                  profile: widget.project.profile,
                  isDarkMode: widget.isDarkMode,
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

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save to gallery
      final String? savedPath = await _screenshotService.saveToGallery(imageBytes);

      if (mounted) {
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Screenshot saved to: $savedPath'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save screenshot. Check permissions.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
