// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_desktop_app/features/convert/settings/states/setting_provider.dart';
import '../../../core/theme/theme_mode_provider.dart';


class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          _SettingsCard(
            title: 'Appearance',
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Theme'),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (_) =>
                    ref.read(themeModeProvider.notifier).setSystem(),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (_) =>
                    ref.read(themeModeProvider.notifier).setLight(),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (_) =>
                    ref.read(themeModeProvider.notifier).setDark(),
              ),
              SwitchListTile(
                title: const Text('Compact Mode'),
                subtitle: const Text('Reduce spacing for dense layouts'),
                value: settings.compactMode,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .toggleCompactMode(v),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SettingsCard(
            title: 'Conversion',
            children: [
              SwitchListTile(
                title: const Text('Auto-open output folder'),
                value: settings.autoOpenFolder,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .toggleAutoOpenFolder(v),
              ),
              SwitchListTile(
                title: const Text('Overwrite existing files'),
                value: settings.overwriteFiles,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .toggleOverwriteFiles(v),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SettingsCard(
            title: 'Behavior',
            children: [
              SwitchListTile(
                title: const Text('Show notifications'),
                value: settings.showNotifications,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .toggleNotifications(v),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SettingsCard(
            title: 'About',
            children: const [
              ListTile(
                title: Text('Application'),
                subtitle: Text('PDF Converter Desktop App'),
              ),
              ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: Text('Platform'),
                subtitle: Text('Windows'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
