import 'package:flutter/material.dart';
import '../models/models.dart';

class MessageInputPanel extends StatefulWidget {
  final Function(String text, MessageSender sender) onSendMessage;
  final VoidCallback? onToggleSender;
  final MessageSender defaultSender;
  final bool isDarkMode;
  final bool enabled;

  const MessageInputPanel({
    super.key,
    required this.onSendMessage,
    required this.defaultSender,
    required this.isDarkMode,
    this.onToggleSender,
    this.enabled = true,
  });

  @override
  State<MessageInputPanel> createState() => _MessageInputPanelState();
}

class _MessageInputPanelState extends State<MessageInputPanel> {
  final TextEditingController _controller = TextEditingController();
  late MessageSender _currentSender;

  @override
  void initState() {
    super.initState();
    _currentSender = widget.defaultSender;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text, _currentSender);
    _controller.clear();
  }

  void _toggleSender() {
    setState(() {
      _currentSender = _currentSender == MessageSender.me 
          ? MessageSender.other 
          : MessageSender.me;
    });
    widget.onToggleSender?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isDarkMode ? const Color(0xFF1F2C34) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Sender toggle button
            _buildSenderToggle(),
            const SizedBox(width: 8),
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: widget.isDarkMode 
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _currentSender == MessageSender.me 
                        ? 'Type a message...' 
                        : 'Type a reply...',
                    hintStyle: TextStyle(
                      color: widget.isDarkMode 
                          ? Colors.white38 
                          : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 10,
                    ),
                  ),
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Container(
              decoration: BoxDecoration(
                color: widget.isDarkMode 
                    ? const Color(0xFF128C7E)
                    : const Color(0xFF128C7E),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: widget.enabled ? _sendMessage : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderToggle() {
    final bool isMe = _currentSender == MessageSender.me;
    
    return GestureDetector(
      onTap: _toggleSender,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isMe 
              ? (widget.isDarkMode ? const Color(0xFF056162) : const Color(0xFFDCF8C6))
              : (widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMe 
                ? (widget.isDarkMode ? Colors.white24 : const Color(0xFFDCF8C6))
                : (widget.isDarkMode ? Colors.white24 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMe ? Icons.person : Icons.person_outline,
              size: 16,
              color: isMe 
                  ? (widget.isDarkMode ? Colors.white : Colors.black54)
                  : (widget.isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 4),
            Text(
              isMe ? 'Me' : 'Other',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isMe 
                    ? (widget.isDarkMode ? Colors.white : Colors.black54)
                    : (widget.isDarkMode ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
