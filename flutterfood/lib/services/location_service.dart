import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// A resolved location with a flag indicating how precise it is.
class CurrentLocation {
  final double latitude;
  final double longitude;

  /// True when the value came from an IP lookup (city-level accuracy) instead
  /// of the device's GPS/location provider.
  final bool isApproximate;

  const CurrentLocation({
    required this.latitude,
    required this.longitude,
    this.isApproximate = false,
  });
}

/// Thrown when the location cannot be determined. The [message] is safe to
/// show to the user.
class LocationException implements Exception {
  final String message;
  final LocationIssue issue;

  const LocationException(
    this.message, {
    this.issue = LocationIssue.unavailable,
  });

  @override
  String toString() => message;
}

/// Why location resolution failed, so the UI can offer the right next step.
enum LocationIssue {
  unavailable,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

/// Resolves the user's current position.
///
/// Uses the platform location provider where one exists. On Linux (and as a
/// fallback when the provider is unavailable) it falls back to an approximate
/// location derived from the public IP address, because geolocator has no
/// Linux implementation.
class LocationService {
  static const _nominatimUserAgent = 'food-delivery-app/1.0 (Flutter)';
  static const _httpTimeout = Duration(seconds: 10);

  bool get _hasDeviceLocation {
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      _ => false,
    };
  }

  Future<CurrentLocation> getCurrentLocation() async {
    Object? deviceError;

    if (_hasDeviceLocation) {
      try {
        return await _fromDevice();
      } on LocationException {
        // Permission problems are meaningful to the user; do not hide them.
        rethrow;
      } catch (e) {
        deviceError = e;
      }
    }

    final ipLocation = await _fromIp();
    if (ipLocation != null) return ipLocation;

    if (deviceError != null) {
      throw const LocationException(
        'Could not determine your location. Check your internet connection and try again.',
      );
    }
    throw const LocationException(
      'Could not determine your location. Please check your internet connection or pick a point on the map.',
    );
  }

  Future<CurrentLocation> _fromDevice() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Please enable location services.',
        issue: LocationIssue.serviceDisabled,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Location permission denied.',
        issue: LocationIssue.permissionDenied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permissions are permanently denied. Please enable them in Settings.',
        issue: LocationIssue.permissionDeniedForever,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return CurrentLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future<CurrentLocation?> _fromIp() async {
    // Two providers so a single service being down/rate-limited does not break
    // the feature. Both are free and keyless.
    const endpoints = ['https://ipwho.is/', 'https://ipapi.co/json/'];

    for (final endpoint in endpoints) {
      try {
        final response = await http
            .get(
              Uri.parse(endpoint),
              headers: const {'Accept': 'application/json'},
            )
            .timeout(_httpTimeout);

        if (response.statusCode != 200) continue;

        final data = jsonDecode(response.body);
        if (data is! Map) continue;

        // ipapi.co reports errors with an `error` field.
        if (data['error'] == true) continue;

        final latitude = _asDouble(data['latitude']);
        final longitude = _asDouble(data['longitude']);
        if (latitude == null || longitude == null) continue;
        if (latitude.abs() > 90 || longitude.abs() > 180) continue;

        return CurrentLocation(
          latitude: latitude,
          longitude: longitude,
          isApproximate: true,
        );
      } on TimeoutException {
        continue;
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Opens this app's permission settings. Useful for `deniedForever`.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens the OS location-services toggle. Useful when GPS is disabled.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Reverse-geocodes coordinates into a human-readable address using
  /// OpenStreetMap's Nominatim service.
  ///
  /// Returns `null` when no address is available; callers should keep whatever
  /// the user already typed in that case.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': latitude.toStringAsFixed(6),
        'lon': longitude.toStringAsFixed(6),
        'zoom': '18',
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'User-Agent': _nominatimUserAgent,
        },
      ).timeout(_httpTimeout);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data is! Map) return null;

      final address = data['address'];
      if (address is Map) {
        final parts = [
          address['house_number'],
          address['road'],
          address['neighbourhood'],
          address['suburb'],
          address['city_district'] ??
              address['district'] ??
              address['county'] ??
              address['state_district'],
          address['city'] ?? address['town'] ?? address['village'],
          address['state'],
          address['country'],
        ]
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();

        // Drop consecutive duplicates (e.g. city and state with the same name).
        final uniqueParts = <String>[];
        for (final part in parts) {
          if (uniqueParts.isEmpty || uniqueParts.last != part) {
            uniqueParts.add(part);
          }
        }

        if (uniqueParts.isNotEmpty) return uniqueParts.join(', ');
      }

      final displayName = data['display_name'];
      if (displayName is String && displayName.trim().isNotEmpty) {
        return displayName;
      }
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }

    return null;
  }
}
