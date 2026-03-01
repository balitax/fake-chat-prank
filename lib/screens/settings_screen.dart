import 'package:flutter/material.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final AdService _adService = AdService();

  late bool _isDarkMode;
  bool _autoScroll = true;
  bool _soundEnabled = true;
  bool _showTimestamps = true;
  bool _showStatus = true;
  bool _watermarkEnabled = true;
  int _defaultDelay = 2;
  bool _isPremium = false;
  Duration? _premiumRemaining;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _loadSettings();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await _adService.isPremiumActive();
    final remaining = await _adService.premiumTimeRemaining();
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
        _premiumRemaining = remaining;
      });
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.getSettings();
    setState(() {
      _autoScroll = settings['autoScroll'] ?? true;
      _soundEnabled = settings['soundEnabled'] ?? true;
      _showTimestamps = settings['showTimestamps'] ?? true;
      _showStatus = settings['showStatus'] ?? true;
      _watermarkEnabled = settings['watermarkEnabled'] ?? true;
      _defaultDelay =
          ((settings['defaultMessageDelay'] ?? 2000) / 1000).round();
    });
  }

  Future<void> _saveSettings() async {
    await _storageService.saveSettings({
      'autoScroll': _autoScroll,
      'soundEnabled': _soundEnabled,
      'showTimestamps': _showTimestamps,
      'showStatus': _showStatus,
      'watermarkEnabled': _watermarkEnabled,
      'defaultMessageDelay': _defaultDelay * 1000,
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m remaining';
    return '${m}m remaining';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sectionColor = isDark
        ? const Color(0xFF00A884)
        : const Color(0xFF008069);
    final subtitleColor = isDark
        ? const Color(0xFF8696A0)
        : const Color(0xFF667781);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance
          _buildSectionHeader('Appearance', sectionColor),
          _buildSettingsTile(
            icon: _isDarkMode ? Icons.dark_mode : Icons.light_mode,
            iconColor: sectionColor,
            title: 'Dark Mode',
            subtitle: 'Use dark theme for the app',
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() => _isDarkMode = value);
                widget.onThemeChanged(value);
                _storageService.setThemeMode(value);
              },
            ),
          ),
          _buildDivider(),

          // Chat Settings
          _buildSectionHeader('Chat Settings', sectionColor),
          _buildSettingsTile(
            icon: Icons.vertical_align_bottom,
            iconColor: sectionColor,
            title: 'Auto Scroll',
            subtitle: 'Auto scroll to new messages',
            trailing: Switch(
              value: _autoScroll,
              onChanged: (value) {
                setState(() => _autoScroll = value);
                _saveSettings();
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.access_time,
            iconColor: sectionColor,
            title: 'Show Timestamps',
            subtitle: 'Display message timestamps',
            trailing: Switch(
              value: _showTimestamps,
              onChanged: (value) {
                setState(() => _showTimestamps = value);
                _saveSettings();
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.done_all,
            iconColor: sectionColor,
            title: 'Show Status',
            subtitle: 'Display read receipts',
            trailing: Switch(
              value: _showStatus,
              onChanged: (value) {
                setState(() => _showStatus = value);
                _saveSettings();
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.timer_outlined,
            iconColor: sectionColor,
            title: 'Message Delay',
            subtitle: '$_defaultDelay seconds',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  onPressed: _defaultDelay > 1
                      ? () {
                          setState(() => _defaultDelay--);
                          _saveSettings();
                        }
                      : null,
                ),
                Text(
                  '$_defaultDelay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: _defaultDelay < 30
                      ? () {
                          setState(() => _defaultDelay++);
                          _saveSettings();
                        }
                      : null,
                ),
              ],
            ),
          ),
          _buildDivider(),

          // Screenshot
          _buildSectionHeader('Screenshot', sectionColor),
          _buildSettingsTile(
            icon: Icons.branding_watermark_outlined,
            iconColor: sectionColor,
            title: 'Watermark',
            subtitle: 'Add watermark to screenshots',
            trailing: Switch(
              value: _watermarkEnabled,
              onChanged: (value) {
                setState(() => _watermarkEnabled = value);
                _saveSettings();
              },
            ),
          ),
          _buildDivider(),

          // Sound
          _buildSectionHeader('Sound', sectionColor),
          _buildSettingsTile(
            icon: Icons.volume_up_outlined,
            iconColor: sectionColor,
            title: 'Message Sound',
            subtitle: 'Play sound for auto messages',
            trailing: Switch(
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
                _saveSettings();
              },
            ),
          ),
          _buildDivider(),

          // Premium
          _buildSectionHeader('Premium Features', sectionColor),
          if (_isPremium && _premiumRemaining != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00A884).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00A884).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF00A884),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Active',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFFE9EDEF)
                                : const Color(0xFF111B21),
                          ),
                        ),
                        Text(
                          _formatDuration(_premiumRemaining!),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF8696A0)
                                : const Color(0xFF667781),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _buildPremiumTile(
            icon: Icons.palette_outlined,
            title: 'Chat Themes',
            subtitle: 'Premium chat backgrounds',
          ),
          _buildPremiumTile(
            icon: Icons.group_outlined,
            title: 'Group Chat',
            subtitle: 'Create group conversations',
          ),
          _buildPremiumTile(
            icon: Icons.hide_image_outlined,
            title: 'Remove Watermark',
            subtitle: 'Export without watermark',
          ),
          _buildPremiumTile(
            icon: Icons.photo_library_outlined,
            title: 'Custom Backgrounds',
            subtitle: 'Use your own backgrounds',
          ),
          _buildDivider(),

          // About
          _buildSectionHeader('About', sectionColor),
          _buildSettingsTile(
            icon: Icons.info_outline,
            iconColor: subtitleColor,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            iconColor: subtitleColor,
            title: 'Disclaimer',
            subtitle: 'For entertainment purposes only',
            onTap: _showDisclaimerDialog,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? const Color(0xFF8696A0) : const Color(0xFF667781),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildDivider() {
    return Divider(
      indent: 72,
      endIndent: 0,
      height: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildPremiumTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isPremium) {
      // Unlocked state
      return _buildSettingsTile(
        icon: icon,
        iconColor: const Color(0xFF00A884),
        title: title,
        subtitle: subtitle,
        trailing: const Icon(
          Icons.check_circle,
          size: 20,
          color: Color(0xFF00A884),
        ),
      );
    }

    return PremiumLockOverlay(
      isLocked: true,
      onUnlocked: () {
        _checkPremiumStatus();
      },
      child: _buildSettingsTile(
        icon: icon,
        iconColor: const Color(0xFF8696A0),
        title: title,
        subtitle: subtitle,
        trailing: Icon(
          Icons.lock_outline,
          size: 16,
          color: isDark
              ? const Color(0xFF8696A0)
              : const Color(0xFF667781),
        ),
      ),
    );
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFA726)),
            SizedBox(width: 8),
            Text('Disclaimer'),
          ],
        ),
        content: const Text(
          'This app is designed for entertainment purposes only.\n\n'
          'Any conversations created using this app are fictional and should not '
          'be used to deceive or mislead others.\n\n'
          'The developer is not responsible for any misuse of this application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I UNDERSTAND'),
          ),
        ],
      ),
    );
  }
}
