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
                          if (message.isVoiceNote)
                            _buildVoiceNote(context, isMe, isDarkMode)
                          else if (message.isLocation)
                            _buildLocationBubble(context, isMe, isDarkMode)
                          else
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
                                    color:
                                        (message.isVoiceNote ||
                                            message.isLocation)
                                        ? (isDarkMode
                                              ? const Color(0xFF8696A0)
                                              : const Color(0xFF667781))
                                        : (isDarkMode
                                              ? const Color(0xFF8696A0)
                                              : const Color(0xFF667781)),
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

  Widget _buildVoiceNote(BuildContext context, bool isMe, bool isDark) {
    final Color iconColor = isDark
        ? const Color(0xFF819196)
        : const Color(0xFF54656F);
    final Color activeColor = isDark
        ? const Color(0xFF3390EC) // Blue for played/active
        : const Color(0xFF24A1DE);

    return Container(
      width: 200,
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, size: 38, color: iconColor),
              // Avatar for voice message
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(Icons.mic, size: 12, color: iconColor),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Pseudo waveform / Progress bar
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0, // Not playing
                    child: Container(color: activeColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDuration(message.voiceDuration ?? 0),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF8696A0)
                        : const Color(0xFF667781),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLocationBubble(BuildContext context, bool isMe, bool isDark) {
    return Container(
      width: 240,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF38434A) : const Color(0xFFE9EDEF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Generic "Map" pattern using grid lines
                CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _MapPlaceholderPainter(isDark: isDark),
                ),
                // Location Pin
                const Icon(Icons.location_on, color: Colors.red, size: 40),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Location',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFE9EDEF)
                        : const Color(0xFF111B21),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.locationAddress ??
                      'Sent at ${_formatTime(message.timestamp)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF8696A0)
                        : const Color(0xFF667781),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          const Center(
            child: Text(
              'View live location',
              style: TextStyle(
                color: Color(0xFF00A884),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  final bool isDark;
  _MapPlaceholderPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1))
      ..strokeWidth = 1.0;

    // Draw grid lines
    for (double i = 0; i <= size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw some random "roads"
    final roadPaint = Paint()
      ..color = (isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1))
      ..strokeWidth = 4.0;

    canvas.drawLine(const Offset(0, 40), Offset(size.width, 80), roadPaint);
    canvas.drawLine(const Offset(60, 0), Offset(100, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
