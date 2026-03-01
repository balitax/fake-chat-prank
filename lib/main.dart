import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'theme/app_theme.dart';
import 'widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storageService = StorageService();
  await storageService.init();

  final adService = AdService();
  await adService.initialize();

  final isDark = await storageService.isDarkMode();

  runApp(FakeChatApp(storageService: storageService, initialDarkMode: isDark));
}

class FakeChatApp extends StatefulWidget {
  final StorageService storageService;
  final bool initialDarkMode;

  const FakeChatApp({
    super.key,
    required this.storageService,
    required this.initialDarkMode,
  });

  @override
  State<FakeChatApp> createState() => FakeChatAppState();
}

class FakeChatAppState extends State<FakeChatApp> with WidgetsBindingObserver {
  late bool _isDarkMode;
  final AdService _adService = AdService();
  bool _hasShownAppOpenAd = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
    WidgetsBinding.instance.addObserver(this);

    // Show app open ad after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownAppOpenAd) {
        _hasShownAppOpenAd = true;
        Future.delayed(const Duration(seconds: 1), () {
          _adService.showAppOpenAd();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _adService.showAppOpenAd();
    }
  }

  void setDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Chat Simulator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        storageService: widget.storageService,
        onThemeChanged: setDarkMode,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;
  List<dynamic> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isDark = await widget.storageService.isDarkMode();
    final projects = await widget.storageService.getAllProjects();

    setState(() {
      _isDarkMode = isDark;
      _projects = projects;
      _isLoading = false;
    });
  }

  Future<void> _toggleTheme() async {
    final newValue = !_isDarkMode;
    await widget.storageService.setThemeMode(newValue);
    setState(() {
      _isDarkMode = newValue;
    });
    widget.onThemeChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('WhatsApp'),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? const Color(0xFF8696A0) : Colors.white,
            ),
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: isDark ? const Color(0xFF8696A0) : Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? const Color(0xFF8696A0) : Colors.white,
            ),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? const Color(0xFF8696A0) : Colors.white,
            ),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(
                      isDarkMode: _isDarkMode,
                      onThemeChanged: (isDark) {
                        setState(() => _isDarkMode = isDark);
                        widget.onThemeChanged(isDark);
                      },
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'new_group', child: Text('New group')),
              const PopupMenuItem(value: 'new_broadcast', child: Text('New broadcast')),
              const PopupMenuItem(value: 'linked', child: Text('Linked devices')),
              const PopupMenuItem(value: 'starred', child: Text('Starred messages')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _projects.isEmpty
                    ? _buildEmptyState()
                    : _buildProjectsList(),
          ),
          // Banner Ad at bottom
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        child: const Icon(Icons.chat, size: 24),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_outlined,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No chats yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first fake conversation',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createNewChat,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('New Chat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        final hasMessages = project.messages.isNotEmpty;
        final lastMessage = hasMessages ? project.messages.last : null;

        return InkWell(
          onTap: () => _openChatEditor(project),
          onLongPress: () => _deleteProject(project.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Hero(
                  tag: 'profile_${project.id}',
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF6B7B8D),
                    child: Text(
                      _getInitials(project.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              project.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatProjectTime(project),
                            style: TextStyle(
                              fontSize: 12,
                              color: index == 0
                                  ? const Color(0xFF00A884)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (lastMessage != null &&
                              lastMessage.sender.index == 0) ...[
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: lastMessage.status.index == 3
                                  ? AppTheme.readTick
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              hasMessages
                                  ? project.messages.last.text
                                  : 'Start a conversation',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (index == 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00A884),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatProjectTime(dynamic project) {
    if (project.messages.isEmpty) return '';
    final time = project.messages.last.timestamp;
    final now = DateTime.now();
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}/${time.year}';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _createNewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatEditorScreen()),
    ).then((_) => _loadData());
  }

  void _openChatEditor(dynamic project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatEditorScreen(existingProject: project),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _deleteProject(String projectId) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete chat?'),
        content: const Text(
          'Messages will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storageService.deleteProject(projectId);
      _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat deleted')),
        );
      }
    }
  }
}
