import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _chatProjectsKey = 'chat_projects';
  static const String _currentProjectKey = 'current_project';
  static const String _themeKey = 'theme_mode';
  static const String _settingsKey = 'app_settings';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  // Chat Projects
  Future<List<ChatProjectModel>> getAllProjects() async {
    await init();
    final String? projectsJson = _prefs.getString(_chatProjectsKey);
    if (projectsJson == null || projectsJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(projectsJson) as List<dynamic>;
      return decoded
          .map((json) => ChatProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveProject(ChatProjectModel project) async {
    await init();
    final projects = await getAllProjects();
    final existingIndex = projects.indexWhere((p) => p.id == project.id);
    
    if (existingIndex >= 0) {
      projects[existingIndex] = project;
    } else {
      projects.add(project);
    }

    final encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await _prefs.setString(_chatProjectsKey, encoded);
  }

  Future<void> deleteProject(String projectId) async {
    await init();
    final projects = await getAllProjects();
    projects.removeWhere((p) => p.id == projectId);
    
    final encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await _prefs.setString(_chatProjectsKey, encoded);
  }

  Future<ChatProjectModel?> getProject(String projectId) async {
    await init();
    final projects = await getAllProjects();
    try {
      return projects.firstWhere((p) => p.id == projectId);
    } catch (e) {
      return null;
    }
  }

  // Current Project
  Future<void> setCurrentProjectId(String? projectId) async {
    await init();
    if (projectId == null) {
      await _prefs.remove(_currentProjectKey);
    } else {
      await _prefs.setString(_currentProjectKey, projectId);
    }
  }

  Future<String?> getCurrentProjectId() async {
    await init();
    return _prefs.getString(_currentProjectKey);
  }

  // Theme Settings
  Future<void> setThemeMode(bool isDark) async {
    await init();
    await _prefs.setBool(_themeKey, isDark);
  }

  Future<bool> isDarkMode() async {
    await init();
    return _prefs.getBool(_themeKey) ?? false;
  }

  // App Settings
  Future<Map<String, dynamic>> getSettings() async {
    await init();
    final String? settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson == null) {
      return _defaultSettings;
    }
    try {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      return _defaultSettings;
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await init();
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  Map<String, dynamic> get _defaultSettings => {
    'autoScroll': true,
    'soundEnabled': true,
    'showTimestamps': true,
    'showStatus': true,
    'watermarkEnabled': true,
    'defaultMessageDelay': 2000,
  };
}
