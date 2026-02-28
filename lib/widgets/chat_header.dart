import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';

class ChatHeader extends StatelessWidget {
  final ChatProfileModel profile;
  final bool isDarkMode;
  final VoidCallback? onBackPressed;
  final VoidCallback? onEditPressed;

  const ChatHeader({
    super.key,
    required this.profile,
    required this.isDarkMode,
    this.onBackPressed,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode ? const Color(0xFF1F2C34) : const Color(0xFF128C7E),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: onBackPressed,
              ),
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              // Name and status
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    _buildStatusText(),
                  ],
                ),
              ),
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.white,
                onPressed: onEditPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white24,
          backgroundImage: profile.profileImagePath != null
              ? FileImage(File(profile.profileImagePath!))
              : null,
          child: profile.profileImagePath == null
              ? Text(
                  _getInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                )
              : null,
        ),
        if (profile.onlineStatus == OnlineStatus.online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF1F2C34) : const Color(0xFF128C7E),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusText() {
    String statusText;
    Color textColor = Colors.white70;

    switch (profile.onlineStatus) {
      case OnlineStatus.online:
        statusText = profile.statusText ?? 'Online';
        break;
      case OnlineStatus.typing:
        statusText = 'typing...';
        textColor = Colors.white;
        break;
      case OnlineStatus.offline:
        statusText = profile.lastSeenText ?? 'Offline';
        break;
    }

    return Text(
      statusText,
      style: TextStyle(
        color: textColor,
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
