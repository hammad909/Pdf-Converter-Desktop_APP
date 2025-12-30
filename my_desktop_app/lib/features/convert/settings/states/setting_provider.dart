import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final bool compactMode;
  final bool autoOpenFolder;
  final bool overwriteFiles;
  final bool showNotifications;

  const AppSettings({
    this.compactMode = false,
    this.autoOpenFolder = true,
    this.overwriteFiles = false,
    this.showNotifications = true,
  });

  AppSettings copyWith({
    bool? compactMode,
    bool? autoOpenFolder,
    bool? overwriteFiles,
    bool? showNotifications,
  }) {
    return AppSettings(
      compactMode: compactMode ?? this.compactMode,
      autoOpenFolder: autoOpenFolder ?? this.autoOpenFolder,
      overwriteFiles: overwriteFiles ?? this.overwriteFiles,
      showNotifications: showNotifications ?? this.showNotifications,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void toggleCompactMode(bool value) =>
      state = state.copyWith(compactMode: value);

  void toggleAutoOpenFolder(bool value) =>
      state = state.copyWith(autoOpenFolder: value);

  void toggleOverwriteFiles(bool value) =>
      state = state.copyWith(overwriteFiles: value);

  void toggleNotifications(bool value) =>
      state = state.copyWith(showNotifications: value);
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);
