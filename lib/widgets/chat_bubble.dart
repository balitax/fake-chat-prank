import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isDarkMode;
  final bool showTimestamp;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTail;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isDarkMode,
    this.showTimestamp = true,
    this.onTap,
    this.onLongPress,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sender == MessageSender.me;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 48 : 8,
          right: isMe ? 8 : 48,
          top: 2,
          bottom: 2,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe 
                    ? AppTheme.getMyMessageBubble(isDarkMode)
                    : AppTheme.getOtherMessageBubble(isDarkMode),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe 
                      ? (showTail ? const Radius.circular(16) : const Radius.circular(4))
                      : const Radius.circular(4),
                  bottomRight: isMe 
                      ? const Radius.circular(4)
                      : (showTail ? const Radius.circular(16) : const Radius.circular(4)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMe 
                          ? (isDarkMode ? Colors.white : Colors.black87)
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (showTimestamp) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isMe 
                                ? (isDarkMode ? Colors.white70 : Colors.black54)
                                : (isDarkMode ? Colors.white60 : Colors.black45),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          _buildStatusIcon(),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = isDarkMode ? Colors.white54 : Colors.black38;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = isDarkMode ? Colors.white54 : Colors.black38;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = isDarkMode ? Colors.white54 : Colors.black38;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = isDarkMode ? Colors.lightBlue[300]! : Colors.blue;
        break;
    }
    
    return Icon(icon, size: 14, color: color);
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }
}
