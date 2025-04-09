/// Utility class to map OpenWeatherMap icon codes to local asset paths
class WeatherIconMapper {
  // Private constructor to prevent instantiation
  WeatherIconMapper._();

  /// Returns the local asset path for a given OpenWeatherMap icon code
  static String getIconAsset(String iconCode) {
    // Default to 2x resolution for better quality on most devices
    // Format is "assets/icons/images/[iconCode]_t@2x.png"
    // The 't' suffix is for transparent background icons
    return 'assets/icons/images/${iconCode}_t@2x.png';
  }

  /// Returns a list of all available icon codes
  static List<String> getAllIconCodes() {
    return [
      '01d', '01n', // clear sky
      '02d', '02n', // few clouds
      '03d', '03n', // scattered clouds
      '04d', '04n', // broken clouds
      '09d', '09n', // shower rain
      '10d', '10n', // rain
      '11d', '11n', // thunderstorm
      '13d', '13n', // snow
      '50d', '50n', // mist
    ];
  }

  /// Returns the appropriate fallback icon based on weather condition
  static String getFallbackIcon(String? condition) {
    final lowercaseCondition = condition?.toLowerCase() ?? '';

    if (lowercaseCondition.contains('clear') ||
        lowercaseCondition.contains('sun')) {
      return 'assets/icons/images/01d_t@2x.png';
    } else if (lowercaseCondition.contains('few clouds')) {
      return 'assets/icons/images/02d_t@2x.png';
    } else if (lowercaseCondition.contains('scattered clouds')) {
      return 'assets/icons/images/03d_t@2x.png';
    } else if (lowercaseCondition.contains('broken clouds') ||
        lowercaseCondition.contains('overcast')) {
      return 'assets/icons/images/04d_t@2x.png';
    } else if (lowercaseCondition.contains('shower rain')) {
      return 'assets/icons/images/09d_t@2x.png';
    } else if (lowercaseCondition.contains('rain')) {
      return 'assets/icons/images/10d_t@2x.png';
    } else if (lowercaseCondition.contains('thunderstorm')) {
      return 'assets/icons/images/11d_t@2x.png';
    } else if (lowercaseCondition.contains('snow')) {
      return 'assets/icons/images/13d_t@2x.png';
    } else if (lowercaseCondition.contains('mist') ||
        lowercaseCondition.contains('fog')) {
      return 'assets/icons/images/50d_t@2x.png';
    }

    // Default
    return 'assets/icons/images/01d_t@2x.png';
  }
}
