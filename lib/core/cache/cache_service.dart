import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/utils/app_logger.dart';

/// Cache service for handling all caching operations
class CacheService {
  final SharedPreferences _prefs;

  /// Cache expiry duration
  final Duration cacheExpiry;

  /// Creates a cache service
  CacheService({
    required SharedPreferences prefs,
    this.cacheExpiry = const Duration(hours: 1),
  }) : _prefs = prefs;

  /// Save data to cache with a key
  Future<bool> saveData<T>({
    required String key,
    required T data,
    Duration? customExpiry,
  }) async {
    try {
      appLogger.i('CacheService: Saving data for key: $key');
      String dataString;

      if (data is String) {
        dataString = data;
      } else {
        dataString = json.encode(data);
      }

      // Save data
      final dataResult = await _prefs.setString(key, dataString);

      // Save timestamp
      final timestampKey = _getTimestampKey(key);
      final timeResult = await _prefs.setInt(
        timestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      // Save expiry (in milliseconds)
      final expiryKey = _getExpiryKey(key);
      final expiryDuration = customExpiry ?? cacheExpiry;
      final expiryResult = await _prefs.setInt(
        expiryKey,
        expiryDuration.inMilliseconds,
      );

      appLogger.i('CacheService: Successfully saved data for key: $key');
      return dataResult && timeResult && expiryResult;
    } catch (e, stackTrace) {
      appLogger.e(
        'CacheService: Error saving data for key: $key',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Gets data from cache by key
  T? getData<T>({
    required String key,
    required T Function(String jsonString) fromJson,
    bool checkExpiry = true,
  }) {
    try {
      appLogger.i('CacheService: Getting data for key: $key');

      // Check if data exists
      if (!_prefs.containsKey(key)) {
        appLogger.w('CacheService: No data found for key: $key');
        return null;
      }

      // Check if data has expired
      if (checkExpiry && isExpired(key)) {
        appLogger.w('CacheService: Data expired for key: $key');
        return null;
      }

      final jsonString = _prefs.getString(key);
      if (jsonString == null) {
        appLogger.w('CacheService: Null data found for key: $key');
        return null;
      }

      if (T == String) {
        return jsonString as T;
      }

      final data = fromJson(jsonString);
      appLogger.i('CacheService: Successfully retrieved data for key: $key');
      return data;
    } catch (e, stackTrace) {
      appLogger.e(
        'CacheService: Error getting data for key: $key',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Checks if data for a key has expired
  bool isExpired(String key) {
    try {
      final timestampKey = _getTimestampKey(key);
      final expiryKey = _getExpiryKey(key);

      // If we don't have timestamp or expiry, consider it expired
      if (!_prefs.containsKey(timestampKey) || !_prefs.containsKey(expiryKey)) {
        return true;
      }

      final timestamp = _prefs.getInt(timestampKey) ?? 0;
      final expiryMillis = _prefs.getInt(expiryKey) ?? 0;

      final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final expiryDuration = Duration(milliseconds: expiryMillis);
      final expiryTime = savedTime.add(expiryDuration);

      final now = DateTime.now();
      return now.isAfter(expiryTime);
    } catch (e, stackTrace) {
      appLogger.e(
        'CacheService: Error checking expiry for key: $key',
        e,
        stackTrace,
      );
      return true; // Consider expired on error
    }
  }

  /// Removes data for a specific key
  Future<bool> removeData(String key) async {
    try {
      appLogger.i('CacheService: Removing data for key: $key');

      final dataResult = await _prefs.remove(key);
      final timestampResult = await _prefs.remove(_getTimestampKey(key));
      final expiryResult = await _prefs.remove(_getExpiryKey(key));

      return dataResult && timestampResult && expiryResult;
    } catch (e, stackTrace) {
      appLogger.e(
        'CacheService: Error removing data for key: $key',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Clear all cached data
  Future<bool> clearAll() async {
    try {
      appLogger.i('CacheService: Clearing all cached data');
      return await _prefs.clear();
    } catch (e, stackTrace) {
      appLogger.e('CacheService: Error clearing all data', e, stackTrace);
      return false;
    }
  }

  /// Save a list of string items
  Future<bool> saveStringList({
    required String key,
    required List<String> items,
    int maxItems = 10,
  }) async {
    try {
      appLogger.i('CacheService: Saving string list for key: $key');

      // Limit the list to the maximum number of items
      if (items.length > maxItems) {
        items = items.sublist(0, maxItems);
      }

      return await _prefs.setStringList(key, items);
    } catch (e, stackTrace) {
      appLogger.e(
        'CacheService: Error saving string list for key: $key',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Get a list of string items
  List<String> getStringList({
    required String key,
    List<String> defaultValue = const [],
  }) {
    try {
      appLogger.i('CacheService: Getting string list for key: $key');
      return _prefs.getStringList(key) ?? defaultValue;
    } catch (e, stackTrace) {
      appLogger.e(
        'CacheService: Error getting string list for key: $key',
        e,
        stackTrace,
      );
      return defaultValue;
    }
  }

  /// Checks if a key exists in the cache
  bool hasKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (e, stackTrace) {
      appLogger.e(
        'CacheService: Error checking if key exists: $key',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Get the timestamp key for a cache key
  String _getTimestampKey(String key) => '$key-timestamp';

  /// Get the expiry key for a cache key
  String _getExpiryKey(String key) => '$key-expiry';
}
