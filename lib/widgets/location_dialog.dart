import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_provider.dart';
import '../services/location_service.dart';

class LocationDialog extends ConsumerStatefulWidget {
  const LocationDialog({super.key});

  @override
  ConsumerState<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends ConsumerState<LocationDialog> {
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with current values
    final locationData = ref.read(locationProvider);
    _cityController.text = locationData['city'] ?? '';
    _countryController.text = locationData['country'] ?? '';
  }

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success =
          await ref.read(locationProvider.notifier).getCurrentLocation();

      if (!success) {
        setState(() {
          _errorMessage =
              'Could not get current location. Please check your location permissions.';
        });
      } else {
        if (mounted) {
          Navigator.of(context).pop(true); // Close dialog with success result
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveManualLocation() async {
    if (_cityController.text.isEmpty || _countryController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both city and country';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For manual location, we'll use default coordinates for now
      // In a real app, you might want to use geocoding to get the actual coordinates
      final success = await ref.read(locationProvider.notifier).updateLocation(
            latitude: LocationService.defaultLatitude,
            longitude: LocationService.defaultLongitude,
            city: _cityController.text.trim(),
            country: _countryController.text.trim(),
          );

      if (!success) {
        setState(() {
          _errorMessage = 'Could not save location. Please try again.';
        });
      } else {
        if (mounted) {
          Navigator.of(context).pop(true); // Close dialog with success result
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Location'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _useCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Or enter location manually:'),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveManualLocation,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
