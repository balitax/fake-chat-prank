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
  
  late bool _isDarkMode;
  bool _autoScroll = true;
  bool _soundEnabled = true;
  bool _showTimestamps = true;
  bool _showStatus = true;
  bool _watermarkEnabled = true;
  int _defaultDelay = 2;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _storageService.getSettings();
    setState(() {
      _autoScroll = settings['autoScroll'] ?? true;
      _soundEnabled = settings['soundEnabled'] ?? true;
      _showTimestamps = settings['showTimestamps'] ?? true;
      _showStatus = settings['showStatus'] ?? true;
      _watermarkEnabled = settings['watermarkEnabled'] ?? true;
      _defaultDelay = ((settings['defaultMessageDelay'] ?? 2000) / 1000).round();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              widget.onThemeChanged(value);
              _storageService.setThemeMode(value);
            },
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          const Divider(),

          // Chat Settings Section
          _buildSectionHeader('Chat Settings'),
          SwitchListTile(
            title: const Text('Auto Scroll'),
            subtitle: const Text('Automatically scroll to new messages'),
            value: _autoScroll,
            onChanged: (value) {
              setState(() {
                _autoScroll = value;
              });
              _saveSettings();
            },
            secondary: const Icon(Icons.vertical_align_bottom),
          ),
          SwitchListTile(
            title: const Text('Show Timestamps'),
            subtitle: const Text('Display message timestamps'),
            value: _showTimestamps,
            onChanged: (value) {
              setState(() {
                _showTimestamps = value;
              });
              _saveSettings();
            },
            secondary: const Icon(Icons.access_time),
          ),
          SwitchListTile(
            title: const Text('Show Status'),
            subtitle: const Text('Display message status icons'),
            value: _showStatus,
            onChanged: (value) {
              setState(() {
                _showStatus = value;
              });
              _saveSettings();
            },
            secondary: const Icon(Icons.done_all),
          ),
          ListTile(
            title: const Text('Default Message Delay'),
            subtitle: Text('$_defaultDelay seconds'),
            leading: const Icon(Icons.timer),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _defaultDelay > 1
                      ? () {
                          setState(() {
                            _defaultDelay--;
                          });
                          _saveSettings();
                        }
                      : null,
                ),
                Text('$_defaultDelay'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _defaultDelay < 30
                      ? () {
                          setState(() {
                            _defaultDelay++;
                          });
                          _saveSettings();
                        }
                      : null,
                ),
              ],
            ),
          ),
          const Divider(),

          // Screenshot Settings Section
          _buildSectionHeader('Screenshot'),
          SwitchListTile(
            title: const Text('Show Watermark'),
            subtitle: const Text('Add watermark to screenshots'),
            value: _watermarkEnabled,
            onChanged: (value) {
              setState(() {
                _watermarkEnabled = value;
              });
              _saveSettings();
            },
            secondary: const Icon(Icons.water_drop),
          ),
          const Divider(),

          // Sound Settings Section
          _buildSectionHeader('Sound'),
          SwitchListTile(
            title: const Text('Message Sound'),
            subtitle: const Text('Play sound for auto messages'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
              _saveSettings();
            },
            secondary: const Icon(Icons.volume_up),
          ),
          const Divider(),

          // Premium Features Section
          _buildSectionHeader('Premium Features'),
          _buildPremiumTile(
            icon: Icons.palette,
            title: 'Chat Themes',
            subtitle: 'Multiple premium chat backgrounds',
          ),
          _buildPremiumTile(
            icon: Icons.group,
            title: 'Group Chat Mode',
            subtitle: 'Create fake group conversations',
          ),
          _buildPremiumTile(
            icon: Icons.water_drop_outlined,
            title: 'Remove Watermark',
            subtitle: 'Export without watermark',
          ),
          _buildPremiumTile(
            icon: Icons.photo_library,
            title: 'Custom Backgrounds',
            subtitle: 'Use your own chat backgrounds',
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Disclaimer'),
            subtitle: const Text('For entertainment purposes only'),
            onTap: () => _showDisclaimerDialog(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPremiumTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return PremiumLockOverlay(
      isLocked: true,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.lock, size: 18),
      ),
    );
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
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
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}
