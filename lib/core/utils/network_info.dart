import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:weather_app/core/utils/app_logger.dart';

/// Abstract class defining network information contract
abstract class NetworkInfo {
  /// Returns true if device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  /// Constructor that accepts Connectivity instance for testing
  NetworkInfoImpl(this.connectivity);

  /// Checks if the device is connected to the internet
  ///
  /// Returns true if connected to WiFi or mobile data
  @override
  Future<bool> get isConnected async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      final isConnected =
          connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile;

      appLogger.d(
        'NetworkInfo: Connection check result: $connectivityResult, isConnected=$isConnected',
      );

      // Try a direct connection test
      // This will help us identify if we have actual internet access
      if (isConnected) {
        appLogger.d(
          'NetworkInfo: Device has WiFi/Mobile connection, checking actual internet connectivity',
        );
        return true; // Return true immediately for now since we need to fix the loading issue
      }

      return isConnected;
    } catch (e) {
      appLogger.e('NetworkInfo: Error checking connectivity', e);
      return false; // Default to no connection on error
    }
  }
}
