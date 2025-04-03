import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_time.dart';
import '../models/mosque_settings.dart';
import '../services/prayer_api_service.dart';
import '../widgets/prayer_card.dart';
import '../widgets/islamic_background.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerApiService _apiService = PrayerApiService();
  PrayerTime? _prayerTimes;
  MosqueSettings _mosqueSettings = MosqueSettings.defaultSettings();
  bool _isLoading = true;
  String? _error;
  String? _activePrayer;
  DateTime? _nextPrayerTime;

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

      final prayerTimes = await _apiService.getPrayerTimes(
        latitude: 25.2048,
        longitude: 55.2708,
        method: 2,
      );

      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
        _updateActivePrayer();
      });
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
    DateTime? nextTime;

    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        nextPrayer = entry.key;
        nextTime = entry.value;
        break;
      }
    }

    setState(() {
      _activePrayer = nextPrayer;
      _nextPrayerTime = nextTime;
    });
  }

  Future<void> _editCongregationTime(String prayer, DateTime adhanTime) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _mosqueSettings.getCongregationTime(prayer, adhanTime),
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

      setState(() {
        _mosqueSettings = _mosqueSettings.copyWith(
          congregationOffsets: {
            ..._mosqueSettings.congregationOffsets,
            prayer: offset,
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: IslamicBackground(
        isDarkMode: themeProvider.isDarkMode,
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
                            themeProvider.isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                          tooltip: 'Toggle theme',
                        ),
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () {
                            // TODO: Implement location selection
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            // TODO: Implement settings
                          },
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
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme.primary,
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
                                                            .colorScheme.primary,
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
                                            _mosqueSettings.getCongregationTime(
                                          'Fajr',
                                          _prayerTimes!.fajr,
                                        ),
                                        isActive: _activePrayer == 'Fajr',
                                        isPast: _prayerTimes!.fajr
                                            .isBefore(DateTime.now()),
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
                                            _mosqueSettings.getCongregationTime(
                                          'Dhuhr',
                                          _prayerTimes!.dhuhr,
                                        ),
                                        isActive: _activePrayer == 'Dhuhr',
                                        isPast: _prayerTimes!.dhuhr
                                            .isBefore(DateTime.now()),
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
                                            _mosqueSettings.getCongregationTime(
                                          'Asr',
                                          _prayerTimes!.asr,
                                        ),
                                        isActive: _activePrayer == 'Asr',
                                        isPast: _prayerTimes!.asr
                                            .isBefore(DateTime.now()),
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
                                            _mosqueSettings.getCongregationTime(
                                          'Maghrib',
                                          _prayerTimes!.maghrib,
                                        ),
                                        isActive: _activePrayer == 'Maghrib',
                                        isPast: _prayerTimes!.maghrib
                                            .isBefore(DateTime.now()),
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
                                            _mosqueSettings.getCongregationTime(
                                          'Isha',
                                          _prayerTimes!.isha,
                                        ),
                                        isActive: _activePrayer == 'Isha',
                                        isPast: _prayerTimes!.isha
                                            .isBefore(DateTime.now()),
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
