import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/location_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/islamic_background.dart';
import '../widgets/location_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final locationData = ref.watch(locationProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: IslamicBackground(
        isDarkMode: isDarkMode,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Settings
              _buildSectionHeader(context, 'Appearance'),
              _buildSettingTile(
                context,
                title: 'Dark Mode',
                subtitle: 'Toggle between light and dark theme',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (_) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ),
              const Divider(),

              // Location Settings
              _buildSectionHeader(context, 'Location'),
              _buildSettingTile(
                context,
                title: 'Current Location',
                subtitle: '${locationData['city']}, ${locationData['country']}',
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => const LocationDialog(),
                    );
                  },
                ),
              ),
              const Divider(),

              // Notification Settings
              _buildSectionHeader(context, 'Notifications'),
              _buildSettingTile(
                context,
                title: 'Prayer Time Notifications',
                subtitle: 'Receive notifications for prayer times',
                trailing: Switch(
                  value: notificationSettings.enablePrayerNotifications,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .togglePrayerNotifications(value);
                  },
                ),
              ),
              _buildSettingTile(
                context,
                title: 'Congregation Time Notifications',
                subtitle: 'Receive notifications for congregation times',
                trailing: Switch(
                  value: notificationSettings.enableCongregationNotifications,
                  onChanged: (value) {
                    ref
                        .read(notificationSettingsProvider.notifier)
                        .toggleCongregationNotifications(value);
                  },
                ),
              ),
              const Divider(),

              // Prayer Settings
              _buildSectionHeader(context, 'Prayer Settings'),
              _buildSettingTile(
                context,
                title: 'Calculation Method',
                subtitle: 'Method used to calculate prayer times',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement calculation method selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calculation method selection coming soon'),
                    ),
                  );
                },
              ),
              _buildSettingTile(
                context,
                title: 'Prayer Time Adjustments',
                subtitle: 'Fine-tune prayer times',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Implement prayer time adjustments
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prayer time adjustments coming soon'),
                    ),
                  );
                },
              ),
              const Divider(),

              // About Section
              _buildSectionHeader(context, 'About'),
              _buildSettingTile(
                context,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              _buildSettingTile(
                context,
                title: 'About This App',
                subtitle: 'Learn more about this app',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Torbaaz Salah Reminder',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(size: 48),
                    applicationLegalese: '© 2023 Torbaaz',
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'A prayer times app that helps Muslims keep track of their daily prayers.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
