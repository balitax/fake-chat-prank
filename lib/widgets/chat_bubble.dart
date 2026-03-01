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
  final Color? myBubbleColor;
  final Color? otherBubbleColor;
  final String? senderName;
  final Color? senderColor;
  final String themeId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isDarkMode,
    this.showTimestamp = true,
    this.onTap,
    this.onLongPress,
    this.showTail = true,
    this.myBubbleColor,
    this.otherBubbleColor,
    this.senderName,
    this.senderColor,
    this.themeId = 'default',
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sender == MessageSender.me;
    final chatTheme = AppTheme.getThemeById(themeId);
    final Color bubbleColor = isMe
        ? (myBubbleColor ?? chatTheme.myBubble(isDarkMode))
        : (otherBubbleColor ?? chatTheme.otherBubble(isDarkMode));

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 64 : (showTail ? 2 : 10),
          right: isMe ? (showTail ? 2 : 10) : 64,
          top: showTail ? 4 : 1,
          bottom: 1,
        ),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: CustomPaint(
                painter: showTail
                    ? _BubbleTailPainter(color: bubbleColor, isMe: isMe)
                    : null,
                child: Container(
                  margin: EdgeInsets.only(
                    left: showTail && !isMe ? 8 : 0,
                    right: showTail && isMe ? 8 : 0,
                  ),
                  padding: const EdgeInsets.only(
                    left: 9,
                    right: 7,
                    top: 6,
                    bottom: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMe ? 8 : (showTail ? 0 : 8)),
                      topRight: Radius.circular(isMe ? (showTail ? 0 : 8) : 8),
                      bottomLeft: const Radius.circular(8),
                      bottomRight: const Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (senderName != null && !isMe && showTail)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            senderName!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: senderColor ?? const Color(0xFF00A884),
                            ),
                          ),
                        ),
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: message.text,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      color: isDarkMode
                                          ? const Color(0xFFE9EDEF)
                                          : const Color(0xFF111B21),
                                      height: 1.3,
                                    ),
                                  ),
                                  TextSpan(
                                    text: isMe
                                        ? '         ${_formatTime(message.timestamp)}  '
                                        : '      ${_formatTime(message.timestamp)} ',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDarkMode
                                        ? const Color(0xFF8696A0)
                                        : const Color(0xFF667781),
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 3),
                                  _buildStatusIcon(),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon = Icons.done;
    Color color = isDarkMode
        ? const Color(0xFF8696A0)
        : const Color(0xFF667781);

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppTheme.readTick;
        break;
    }

    return Icon(icon, size: 16, color: color);
  }

  String _formatTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isMe;

  _BubbleTailPainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (isMe) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width + 8, 0);
      path.quadraticBezierTo(size.width + 8, 10, size.width, 10);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(-8, 0);
      path.quadraticBezierTo(-8, 10, 0, 10);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isMe != isMe;
  }
}
