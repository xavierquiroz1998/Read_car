class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'ReadCar';
  static const String appVersion = '1.0.0';

  // OBD2 connection
  /// Common name fragments found in ELM327 Bluetooth device names
  static const List<String> elm327Names = [
    'obd',
    'elm',
    'obdii',
    'elm327',
    'vlink',
    'icar',
    'carista',
  ];

  /// Timeout waiting for a single ELM327 response
  static const Duration commandTimeout = Duration(seconds: 5);

  /// Delay after ATZ reset before sending next command
  static const Duration resetDelay = Duration(milliseconds: 1500);

  /// Interval between full dashboard polling cycles
  static const Duration pollingInterval = Duration(milliseconds: 300);

  /// Max retries on a failed command before reporting error
  static const int maxCommandRetries = 3;

  // Fuel calculation defaults
  /// Stoichiometric air-fuel ratio for petrol engines
  static const double stoichiometricAfr = 14.7;

  /// Default engine displacement in litres (user-configurable)
  static const double defaultDisplacementL = 1.6;

  /// Petrol density kg/L
  static const double petrolDensityKgPerL = 0.74;

  /// Default price per litre (can be overridden by user)
  static const double defaultFuelPricePerL = 5500.0; // COP

  // History
  static const int maxHistoryEntries = 500;
}
