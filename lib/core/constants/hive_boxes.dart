/// Hive box name constants — avoids magic strings scattered throughout code.
class HiveBoxes {
  HiveBoxes._();

  static const String tripSession = 'trip_sessions';
  static const String dtcHistory = 'dtc_history';
  static const String appSettings = 'app_settings';
}

/// Hive type IDs — must be unique across all registered adapters.
class HiveTypeIds {
  HiveTypeIds._();

  static const int tripSession = 0;
  static const int dtcRecord = 1;
}
