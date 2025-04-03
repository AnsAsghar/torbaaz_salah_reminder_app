import 'package:flutter/material.dart';
import '../models/mosque_settings.dart';

class PrayerCard extends StatelessWidget {
  final String name;
  final DateTime adhanTime;
  final DateTime congregationTime;
  final bool isActive;
  final bool isPast;
  final VoidCallback? onCongregationTimeEdit;

  const PrayerCard({
    super.key,
    required this.name,
    required this.adhanTime,
    required this.congregationTime,
    required this.isActive,
    required this.isPast,
    this.onCongregationTimeEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: isActive ? 8 : 2,
        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isPast
                                  ? Colors.grey.withOpacity(0.3)
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            _getPrayerIcon(),
                            color: isPast
                                ? Colors.grey
                                : Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: isPast ? Colors.grey : null,
                                    fontWeight:
                                        isActive ? FontWeight.bold : null,
                                  ),
                            ),
                            if (isActive)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'NEXT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeColumn(
                      context,
                      'Adhan',
                      adhanTime,
                      Icons.notifications_outlined,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    _buildTimeColumn(
                      context,
                      'Congregation',
                      congregationTime,
                      Icons.groups_outlined,
                      showEditButton: !isPast && onCongregationTimeEdit != null,
                      onEdit: onCongregationTimeEdit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    BuildContext context,
    String label,
    DateTime time,
    IconData icon, {
    bool showEditButton = false,
    VoidCallback? onEdit,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPast
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPast ? Colors.grey : null,
                    ),
              ),
              if (showEditButton)
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: onEdit,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(time),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isPast ? Colors.grey : null,
                  fontWeight: isActive ? FontWeight.bold : null,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getPrayerIcon() {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.sunny;
      case 'Maghrib':
        return Icons.nights_stay;
      case 'Isha':
        return Icons.dark_mode;
      default:
        return Icons.access_time;
    }
  }
}
