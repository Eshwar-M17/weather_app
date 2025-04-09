import 'package:weather_app/core/utils/app_logger.dart';
import 'package:weather_app/core/utils/json_parser.dart';

/// Air Quality Index (AQI) levels according to OpenWeatherMap
enum AirQualityLevel {
  /// AQI 1: Good
  good,

  /// AQI 2: Fair
  fair,

  /// AQI 3: Moderate
  moderate,

  /// AQI 4: Poor
  poor,

  /// AQI 5: Very Poor
  veryPoor,

  /// Unknown AQI
  unknown,
}

/// Model class for Air Quality data from OpenWeatherMap API
class AirQualityModel {
  /// Air Quality Index (1-5)
  final int aqi;

  /// Carbon monoxide concentration (μg/m3)
  final double co;

  /// Nitrogen monoxide concentration (μg/m3)
  final double no;

  /// Nitrogen dioxide concentration (μg/m3)
  final double no2;

  /// Ozone concentration (μg/m3)
  final double o3;

  /// Sulphur dioxide concentration (μg/m3)
  final double so2;

  /// Fine particulate matter concentration (μg/m3)
  final double pm2_5;

  /// Coarse particulate matter concentration (μg/m3)
  final double pm10;

  /// Ammonia concentration (μg/m3)
  final double nh3;

  /// Timestamp of the data
  final DateTime timestamp;

  /// Latitude
  final double lat;

  /// Longitude
  final double lon;

  /// Creates an AirQualityModel
  const AirQualityModel({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
    required this.timestamp,
    required this.lat,
    required this.lon,
  });

  /// Creates an AirQualityModel from JSON
  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    try {
      appLogger.d('Parsing air quality JSON');

      const logPrefix = 'AirQualityModel';

      // Extract coordinates
      double lat = 0.0, lon = 0.0;
      final coords = json['coord'];
      if (coords is Map<String, dynamic>) {
        lat = JsonParser.parseDouble(
          coords,
          'lat',
          defaultValue: 0.0,
          logPrefix: logPrefix,
        );
        lon = JsonParser.parseDouble(
          coords,
          'lon',
          defaultValue: 0.0,
          logPrefix: logPrefix,
        );
      } else if (coords is List<dynamic> && coords.length >= 2) {
        // Handle the case where coords might be a list [lat, lon]
        lat = coords[0].toDouble();
        lon = coords[1].toDouble();
      }

      // Get the air quality data from the list
      final list = json['list'] as List<dynamic>?;
      if (list == null || list.isEmpty) {
        throw FormatException('Missing air quality data in JSON response');
      }

      final data = list[0] as Map<String, dynamic>;

      // Parse timestamp
      final dt = JsonParser.parseInt(data, 'dt', logPrefix: logPrefix);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(dt * 1000);

      // Get main and components data
      final main =
          JsonParser.getNestedObject(data, 'main', logPrefix: logPrefix) ?? {};
      final components =
          JsonParser.getNestedObject(
            data,
            'components',
            logPrefix: logPrefix,
          ) ??
          {};

      // Parse AQI
      final aqi = JsonParser.parseInt(
        main,
        'aqi',
        defaultValue: 0,
        logPrefix: logPrefix,
      );

      // Parse components
      final co = JsonParser.parseDouble(
        components,
        'co',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );
      final no = JsonParser.parseDouble(
        components,
        'no',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );
      final no2 = JsonParser.parseDouble(
        components,
        'no2',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );
      final o3 = JsonParser.parseDouble(
        components,
        'o3',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );
      final so2 = JsonParser.parseDouble(
        components,
        'so2',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );
      final pm2_5 = JsonParser.parseDouble(
        components,
        'pm2_5',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );
      final pm10 = JsonParser.parseDouble(
        components,
        'pm10',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );
      final nh3 = JsonParser.parseDouble(
        components,
        'nh3',
        defaultValue: 0.0,
        logPrefix: logPrefix,
      );

      return AirQualityModel(
        aqi: aqi,
        co: co,
        no: no,
        no2: no2,
        o3: o3,
        so2: so2,
        pm2_5: pm2_5,
        pm10: pm10,
        nh3: nh3,
        timestamp: timestamp,
        lat: lat,
        lon: lon,
      );
    } catch (e, stackTrace) {
      appLogger.e('Error parsing air quality data', e, stackTrace);
      rethrow;
    }
  }

  /// Converts AirQualityModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'coord': [lat, lon],
      'list': [
        {
          'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
          'main': {'aqi': aqi},
          'components': {
            'co': co,
            'no': no,
            'no2': no2,
            'o3': o3,
            'so2': so2,
            'pm2_5': pm2_5,
            'pm10': pm10,
            'nh3': nh3,
          },
        },
      ],
    };
  }

  /// Get the air quality level based on AQI
  AirQualityLevel get airQualityLevel {
    switch (aqi) {
      case 1:
        return AirQualityLevel.good;
      case 2:
        return AirQualityLevel.fair;
      case 3:
        return AirQualityLevel.moderate;
      case 4:
        return AirQualityLevel.poor;
      case 5:
        return AirQualityLevel.veryPoor;
      default:
        return AirQualityLevel.unknown;
    }
  }

  /// Get a user-friendly description of the air quality
  String get description {
    switch (airQualityLevel) {
      case AirQualityLevel.good:
        return 'Good - Air quality is considered satisfactory, and air pollution poses little or no risk.';
      case AirQualityLevel.fair:
        return 'Fair - Air quality is acceptable; however, there may be a moderate health concern for a very small number of people.';
      case AirQualityLevel.moderate:
        return 'Moderate - Members of sensitive groups may experience health effects. The general public is less likely to be affected.';
      case AirQualityLevel.poor:
        return 'Poor - Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.';
      case AirQualityLevel.veryPoor:
        return 'Very Poor - Health warnings of emergency conditions. The entire population is more likely to be affected.';
      case AirQualityLevel.unknown:
        return 'Air quality information unavailable.';
    }
  }

  /// Get a short title/label for the AQI level
  String get levelLabel {
    switch (airQualityLevel) {
      case AirQualityLevel.good:
        return '1-Good';
      case AirQualityLevel.fair:
        return '2-Fair';
      case AirQualityLevel.moderate:
        return '3-Moderate';
      case AirQualityLevel.poor:
        return '4-Poor';
      case AirQualityLevel.veryPoor:
        return '5-Very Poor';
      case AirQualityLevel.unknown:
        return 'Unknown';
    }
  }

  /// Get normalized value for UI display (0.0-1.0)
  double get normalizedValue {
    // Convert AQI 1-5 to 0.0-1.0 for progress indicators
    return ((aqi - 1) / 4.0).clamp(0.0, 1.0);
  }
}
