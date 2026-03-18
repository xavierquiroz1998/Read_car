/// Lookup table for common DTC codes.
/// Extend this as needed — in a production app this would come from a
/// bundled SQLite database or a remote API.
class DtcDecoder {
  DtcDecoder._();

  static const Map<String, String> _descriptions = {
    // ── Fuel & Air Metering ────────────────────────────────────────────────
    'P0087': 'Fuel Rail / System Pressure Too Low',
    'P0088': 'Fuel Rail / System Pressure Too High',
    'P0100': 'Mass Air Flow Circuit Malfunction',
    'P0101': 'Mass Air Flow Circuit Range / Performance',
    'P0102': 'Mass Air Flow Circuit Low Input',
    'P0103': 'Mass Air Flow Circuit High Input',
    'P0110': 'Intake Air Temperature Circuit Malfunction',
    'P0112': 'Intake Air Temperature Circuit Low Input',
    'P0113': 'Intake Air Temperature Circuit High Input',
    'P0120': 'Throttle Position Sensor Circuit Malfunction',
    'P0121': 'Throttle Position Sensor Range / Performance',
    'P0130': 'O2 Sensor Circuit Malfunction (Bank 1, Sensor 1)',
    'P0133': 'O2 Sensor Slow Response (Bank 1, Sensor 1)',
    'P0135': 'O2 Sensor Heater Circuit Malfunction (Bank 1, Sensor 1)',
    'P0171': 'System Too Lean (Bank 1)',
    'P0172': 'System Too Rich (Bank 1)',

    // ── Ignition / Misfire ─────────────────────────────────────────────────
    'P0300': 'Random / Multiple Cylinder Misfire Detected',
    'P0301': 'Cylinder 1 Misfire Detected',
    'P0302': 'Cylinder 2 Misfire Detected',
    'P0303': 'Cylinder 3 Misfire Detected',
    'P0304': 'Cylinder 4 Misfire Detected',
    'P0305': 'Cylinder 5 Misfire Detected',
    'P0306': 'Cylinder 6 Misfire Detected',

    // ── Catalytic Converter ────────────────────────────────────────────────
    'P0420': 'Catalyst System Efficiency Below Threshold (Bank 1)',
    'P0421': 'Warm Up Catalyst Efficiency Below Threshold (Bank 1)',
    'P0430': 'Catalyst System Efficiency Below Threshold (Bank 2)',

    // ── EGR / Evaporative ──────────────────────────────────────────────────
    'P0400': 'Exhaust Gas Recirculation Flow Malfunction',
    'P0401': 'Exhaust Gas Recirculation Flow Insufficient',
    'P0440': 'Evaporative Emission Control System Malfunction',
    'P0441': 'Evaporative Emission Control System Incorrect Purge Flow',
    'P0442': 'Evaporative Emission Control System Leak Detected (small)',
    'P0455': 'Evaporative Emission Control System Leak Detected (large)',

    // ── Engine Temperature / Cooling ───────────────────────────────────────
    'P0115': 'Engine Coolant Temperature Circuit Malfunction',
    'P0116': 'Engine Coolant Temperature Circuit Range / Performance',
    'P0117': 'Engine Coolant Temperature Circuit Low Input',
    'P0118': 'Engine Coolant Temperature Circuit High Input',
    'P0125': 'Insufficient Coolant Temperature for Closed-Loop Fuel Control',

    // ── Transmission ──────────────────────────────────────────────────────
    'P0700': 'Transmission Control System Malfunction',
    'P0705': 'Transmission Range Sensor Circuit Malfunction',
    'P0715': 'Input / Turbine Speed Sensor Circuit Malfunction',
    'P0720': 'Output Speed Sensor Circuit Malfunction',
    'P0730': 'Incorrect Gear Ratio',

    // ── Battery / Charging ────────────────────────────────────────────────
    'P0562': 'System Voltage Low',
    'P0563': 'System Voltage High',
    'P0600': 'Serial Communication Link Malfunction',

    // ── Generic placeholders ──────────────────────────────────────────────
    'U0001': 'High Speed CAN Communication Bus',
    'U0100': 'Lost Communication With ECM / PCM',
    'B0001': 'Driver Frontal Stage 1 Deployment Control',
    'C0035': 'Left Front Wheel Speed Sensor Circuit',
  };

  /// Returns a human-readable description for [code], or a generic
  /// fallback if the code is not in the table.
  static String describe(String code) {
    return _descriptions[code.toUpperCase()] ??
        'Unknown fault code ($code) — consult a mechanic';
  }

  /// Returns the severity label based on DTC category.
  static DtcSeverity severity(String code) {
    if (code.isEmpty) return DtcSeverity.unknown;
    return switch (code[0].toUpperCase()) {
      'P' => DtcSeverity.powertrain,
      'C' => DtcSeverity.chassis,
      'B' => DtcSeverity.body,
      'U' => DtcSeverity.network,
      _ => DtcSeverity.unknown,
    };
  }
}

enum DtcSeverity {
  powertrain,
  chassis,
  body,
  network,
  unknown;

  String get label => switch (this) {
        DtcSeverity.powertrain => 'Powertrain',
        DtcSeverity.chassis => 'Chassis',
        DtcSeverity.body => 'Body',
        DtcSeverity.network => 'Network',
        DtcSeverity.unknown => 'Unknown',
      };
}
