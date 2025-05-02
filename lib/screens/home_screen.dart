import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_time.dart';
import '../services/prayer_api_service.dart';
import '../widgets/prayer_card.dart';
import '../widgets/islamic_background.dart';
import '../providers/theme_provider.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/prayer_notification_provider.dart';
import '../widgets/location_dialog.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PrayerApiService _apiService = PrayerApiService();
  PrayerTime? _prayerTimes;
  bool _isLoading = true;
  bool _isNextDay = false;
  String? _error;
  String? _activePrayer;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get location data from provider
      final locationData = ref.read(locationProvider);
      final city = locationData['city'] as String;
      final country = locationData['country'] as String;
      final latitude = locationData['latitude'] as double;
      final longitude = locationData['longitude'] as double;

      // Try first with the city-based API which is more reliable
      try {
        final prayerTimes = await _apiService.getPrayerTimesByCity(
          city: city,
          country: country,
          method: 8, // Using method 8 as specified in your API URL
        );

        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
          _isNextDay = false;
          _updateActivePrayer();
        });

        // Schedule notifications for prayer times
        final notificationSettings = ref.read(notificationSettingsProvider);
        final prayerNotificationService =
            ref.read(prayerNotificationServiceProvider);
        final mosqueSettings = ref.read(mosqueSettingsProvider);

        await prayerNotificationService.schedulePrayerNotifications(
          prayerTimes,
          enablePrayerNotifications:
              notificationSettings.enablePrayerNotifications,
          enableCongregationNotifications:
              notificationSettings.enableCongregationNotifications,
          mosqueSettings: mosqueSettings,
        );
        return;
      } catch (cityApiError) {
        if (kDebugMode) {
          print('City API failed, falling back to coordinates: $cityApiError');
        }
        // If city-based API fails, fall back to coordinates
      }

      // Fallback to coordinates-based API
      final prayerTimes = await _apiService.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        method: 2,
      );

      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
        _isNextDay = false;
        _updateActivePrayer();
      });

      // Schedule notifications for prayer times
      final notificationSettings = ref.read(notificationSettingsProvider);
      final prayerNotificationService =
          ref.read(prayerNotificationServiceProvider);
      final mosqueSettings = ref.read(mosqueSettingsProvider);

      await prayerNotificationService.schedulePrayerNotifications(
        prayerTimes,
        enablePrayerNotifications:
            notificationSettings.enablePrayerNotifications,
        enableCongregationNotifications:
            notificationSettings.enableCongregationNotifications,
        mosqueSettings: mosqueSettings,
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateActivePrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final prayers = {
      'Fajr': _prayerTimes!.fajr,
      'Dhuhr': _prayerTimes!.dhuhr,
      'Asr': _prayerTimes!.asr,
      'Maghrib': _prayerTimes!.maghrib,
      'Isha': _prayerTimes!.isha,
    };

    String? nextPrayer;

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        nextPrayer = entry.key;
        break;
      }
    }

    // If no next prayer found (all prayers for today are over),
    // set Fajr as the next prayer and load next day's prayer times
    if (nextPrayer == null) {
      nextPrayer = 'Fajr';
      _loadNextDayPrayerTimes();
    }

    setState(() {
      _activePrayer = nextPrayer;
    });
  }

  // Load next day's prayer times
  Future<void> _loadNextDayPrayerTimes() async {
    try {
      // Get tomorrow's date
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      // Get location data from provider
      final locationData = ref.read(locationProvider);
      final city = locationData['city'] as String;
      final country = locationData['country'] as String;

      if (kDebugMode) {
        print(
            'Loading next day\'s prayer times for ${tomorrow.day}-${tomorrow.month}-${tomorrow.year}');
      }

      // Try first with the city-based API which is more reliable
      try {
        final prayerTimes = await _apiService.getPrayerTimesByCity(
          city: city,
          country: country,
          method: 8, // Using method 8 as specified in your API URL
          date: tomorrow,
        );

        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
          _isNextDay = true;
        });
        return;
      } catch (cityApiError) {
        if (kDebugMode) {
          print(
              'City API failed for next day, falling back to coordinates: $cityApiError');
        }
        // If city-based API fails, fall back to coordinates
      }

      // Fallback to coordinates-based API
      final latitude = locationData['latitude'] as double;
      final longitude = locationData['longitude'] as double;

      final prayerTimes = await _apiService.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        method: 2,
        date: tomorrow,
      );

      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
        _isNextDay = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading next day\'s prayer times: $e');
      }
      // Don't update state or show error for next day loading failures
      // as we still want to show today's prayer times
    }
  }

  Future<void> _editCongregationTime(String prayer, DateTime adhanTime) async {
    // Get mosque settings from provider
    final mosqueSettings = ref.read(mosqueSettingsProvider);

    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        mosqueSettings.getCongregationTime(prayer, adhanTime),
      ),
    );

    if (newTime != null) {
      final now = DateTime.now();
      final newDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        newTime.hour,
        newTime.minute,
      );
      final offset = newDateTime.difference(adhanTime);

      // Update mosque settings using the provider
      await ref
          .read(mosqueSettingsProvider.notifier)
          .updateCongregationOffset(prayer, offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Riverpod to get the theme state and mosque settings
    final isDarkMode = ref.watch(themeProvider);
    final mosqueSettings = ref.watch(mosqueSettingsProvider);

    return Scaffold(
      body: IslamicBackground(
        isDarkMode: isDarkMode,
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prayer Times',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          ),
                          onPressed: () {
                            // Toggle theme using the ThemeNotifier
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                          tooltip: 'Toggle theme',
                        ),
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => const LocationDialog(),
                            );

                            if (result == true) {
                              // Reload prayer times with new location
                              _loadPrayerTimes();
                            }
                          },
                          tooltip: 'Change location',
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            ).then((_) {
                              // Reload prayer times when returning from settings
                              // in case location was changed
                              _loadPrayerTimes();
                            });
                          },
                          tooltip: 'Settings',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading prayer times',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32),
                                  child: Text(
                                    _error!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _loadPrayerTimes,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadPrayerTimes,
                            child: CustomScrollView(
                              slivers: [
                                // Info Section
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_activePrayer != null)
                                          Text(
                                            'Next Prayer: $_activePrayer',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                          ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withAlpha(25),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(50),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'You can adjust congregation times according to your local mosque schedule by tapping the edit icon.',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Prayer Cards
                                if (_prayerTimes != null)
                                  SliverList(
                                    delegate: SliverChildListDelegate([
                                      PrayerCard(
                                        name: 'Fajr',
                                        adhanTime: _prayerTimes!.fajr,
                                        congregationTime:
                                            mosqueSettings.getCongregationTime(
                                          'Fajr',
                                          _prayerTimes!.fajr,
                                        ),
                                        isActive: _activePrayer == 'Fajr',
                                        isPast: _prayerTimes!.fajr
                                            .isBefore(DateTime.now()),
                                        isNextDay: _isNextDay,
                                        onCongregationTimeEdit: () =>
                                            _editCongregationTime(
                                          'Fajr',
                                          _prayerTimes!.fajr,
                                        ),
                                      ),
                                      PrayerCard(
                                        name: 'Dhuhr',
                                        adhanTime: _prayerTimes!.dhuhr,
                                        congregationTime:
                                            mosqueSettings.getCongregationTime(
                                          'Dhuhr',
                                          _prayerTimes!.dhuhr,
                                        ),
                                        isActive: _activePrayer == 'Dhuhr',
                                        isPast: _prayerTimes!.dhuhr
                                            .isBefore(DateTime.now()),
                                        isNextDay: _isNextDay,
                                        onCongregationTimeEdit: () =>
                                            _editCongregationTime(
                                          'Dhuhr',
                                          _prayerTimes!.dhuhr,
                                        ),
                                      ),
                                      PrayerCard(
                                        name: 'Asr',
                                        adhanTime: _prayerTimes!.asr,
                                        congregationTime:
                                            mosqueSettings.getCongregationTime(
                                          'Asr',
                                          _prayerTimes!.asr,
                                        ),
                                        isActive: _activePrayer == 'Asr',
                                        isPast: _prayerTimes!.asr
                                            .isBefore(DateTime.now()),
                                        isNextDay: _isNextDay,
                                        onCongregationTimeEdit: () =>
                                            _editCongregationTime(
                                          'Asr',
                                          _prayerTimes!.asr,
                                        ),
                                      ),
                                      PrayerCard(
                                        name: 'Maghrib',
                                        adhanTime: _prayerTimes!.maghrib,
                                        congregationTime:
                                            mosqueSettings.getCongregationTime(
                                          'Maghrib',
                                          _prayerTimes!.maghrib,
                                        ),
                                        isActive: _activePrayer == 'Maghrib',
                                        isPast: _prayerTimes!.maghrib
                                            .isBefore(DateTime.now()),
                                        isNextDay: _isNextDay,
                                        onCongregationTimeEdit: () =>
                                            _editCongregationTime(
                                          'Maghrib',
                                          _prayerTimes!.maghrib,
                                        ),
                                      ),
                                      PrayerCard(
                                        name: 'Isha',
                                        adhanTime: _prayerTimes!.isha,
                                        congregationTime:
                                            mosqueSettings.getCongregationTime(
                                          'Isha',
                                          _prayerTimes!.isha,
                                        ),
                                        isActive: _activePrayer == 'Isha',
                                        isPast: _prayerTimes!.isha
                                            .isBefore(DateTime.now()),
                                        isNextDay: _isNextDay,
                                        onCongregationTimeEdit: () =>
                                            _editCongregationTime(
                                          'Isha',
                                          _prayerTimes!.isha,
                                        ),
                                      ),
                                    ]),
                                  ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
