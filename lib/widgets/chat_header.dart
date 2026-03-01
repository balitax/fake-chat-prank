import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';

class ChatHeader extends StatelessWidget {
  final ChatProfileModel profile;
  final bool isDarkMode;
  final VoidCallback onEditPressed;

  const ChatHeader({
    super.key,
    required this.profile,
    required this.isDarkMode,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final appBarBg = isDarkMode
        ? const Color(0xFF1F2C34)
        : const Color(0xFF008069);
    final iconColor = isDarkMode
        ? const Color(0xFF8696A0)
        : Colors.white;

    return Container(
      color: appBarBg,
      padding: const EdgeInsets.only(left: 0, right: 4, top: 4, bottom: 4),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back + Avatar together (WhatsApp style)
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, color: iconColor, size: 24),
                    const SizedBox(width: 4),
                    Hero(
                      tag: 'profile_${profile.name}',
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF6B7B8D),
                        backgroundImage: profile.profileImagePath != null
                            ? FileImage(File(profile.profileImagePath!))
                            : null,
                        child: profile.profileImagePath == null
                            ? Text(
                                _getInitials(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Name + Status
            Expanded(
              child: InkWell(
                onTap: onEditPressed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFE9EDEF) : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    _buildStatusText(),
                  ],
                ),
              ),
            ),
            // Action icons
            IconButton(
              icon: Icon(Icons.videocam_rounded, color: iconColor, size: 22),
              onPressed: () {},
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: Icon(Icons.call, color: iconColor, size: 20),
              onPressed: () {},
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: iconColor, size: 22),
              onPressed: () {},
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  bool get isDark => isDarkMode;

  Widget _buildStatusText() {
    String statusText;

    switch (profile.onlineStatus) {
      case OnlineStatus.online:
        statusText = 'online';
        break;
      case OnlineStatus.typing:
        statusText = 'typing...';
        break;
      case OnlineStatus.offline:
        statusText = profile.lastSeenText ?? 'last seen today at 10:30 AM';
        break;
    }

    return Text(
      statusText,
      style: TextStyle(
        color: isDark
            ? const Color(0xFF8696A0)
            : Colors.white.withValues(alpha: 0.8),
        fontSize: 13,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getInitials() {
    final parts = profile.name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
