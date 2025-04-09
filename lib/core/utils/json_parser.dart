import 'package:weather_app/core/utils/app_logger.dart';

/// Utility class for safely parsing JSON data
class JsonParser {
  /// Parse a value from JSON with proper error handling
  static T? parse<T>(
    dynamic json,
    String key,
    T Function(dynamic value) converter, {
    String? logPrefix,
  }) {
    try {
      final value = json[key];
      if (value == null) return null;
      return converter(value);
    } catch (e) {
      final prefix = logPrefix != null ? '$logPrefix: ' : '';
      appLogger.w('${prefix}Error parsing $key: $e');
      return null;
    }
  }

  /// Parse an int from JSON with a default value
  static int parseInt(
    dynamic json,
    String key, {
    int defaultValue = 0,
    String? logPrefix,
  }) {
    return parse(
          json,
          key,
          (value) => (value as num).toInt(),
          logPrefix: logPrefix,
        ) ??
        defaultValue;
  }

  /// Parse a double from JSON with a default value
  static double parseDouble(
    dynamic json,
    String key, {
    double defaultValue = 0.0,
    String? logPrefix,
  }) {
    return parse(
          json,
          key,
          (value) => (value as num).toDouble(),
          logPrefix: logPrefix,
        ) ??
        defaultValue;
  }

  /// Parse a string from JSON with a default value
  static String parseString(
    dynamic json,
    String key, {
    String defaultValue = '',
    String? logPrefix,
  }) {
    return parse(
          json,
          key,
          (value) => value.toString(),
          logPrefix: logPrefix,
        ) ??
        defaultValue;
  }

  /// Parse a boolean from JSON with a default value
  static bool parseBool(
    dynamic json,
    String key, {
    bool defaultValue = false,
    String? logPrefix,
  }) {
    return parse(
          json,
          key,
          (value) =>
              value is bool ? value : value.toString().toLowerCase() == 'true',
          logPrefix: logPrefix,
        ) ??
        defaultValue;
  }

  /// Parse a DateTime from a Unix timestamp (seconds) with a default value
  static DateTime parseDateTime(
    dynamic json,
    String key, {
    DateTime? defaultValue,
    String? logPrefix,
  }) {
    try {
      final timestamp = json[key];
      if (timestamp == null) return defaultValue ?? DateTime.now();
      return DateTime.fromMillisecondsSinceEpoch(
        (timestamp as num).toInt() * 1000,
      );
    } catch (e) {
      final prefix = logPrefix != null ? '$logPrefix: ' : '';
      appLogger.w('${prefix}Error parsing DateTime $key: $e');
      return defaultValue ?? DateTime.now();
    }
  }

  /// Parse a list from JSON with a default empty list
  static List<T> parseList<T>(
    dynamic json,
    String key,
    T Function(dynamic item) itemConverter, {
    String? logPrefix,
  }) {
    try {
      final list = json[key];
      if (list == null || list is! List) return [];
      return list.map((item) => itemConverter(item)).toList();
    } catch (e) {
      final prefix = logPrefix != null ? '$logPrefix: ' : '';
      appLogger.w('${prefix}Error parsing list $key: $e');
      return [];
    }
  }

  /// Get a nested object from JSON
  static Map<String, dynamic>? getNestedObject(
    dynamic json,
    String key, {
    String? logPrefix,
  }) {
    try {
      final value = json[key];
      if (value == null) return null;
      return value as Map<String, dynamic>;
    } catch (e) {
      final prefix = logPrefix != null ? '$logPrefix: ' : '';
      appLogger.w('${prefix}Error getting nested object $key: $e');
      return null;
    }
  }

  /// Get the first item of a list if it exists
  static dynamic getFirstListItem(
    dynamic json,
    String key, {
    String? logPrefix,
  }) {
    try {
      final list = json[key];
      if (list == null || list is! List || list.isEmpty) return null;
      return list[0];
    } catch (e) {
      final prefix = logPrefix != null ? '$logPrefix: ' : '';
      appLogger.w('${prefix}Error getting first list item $key: $e');
      return null;
    }
  }
}
