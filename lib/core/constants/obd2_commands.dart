/// All ELM327 AT commands and OBD2 PID commands.
/// Single source of truth — never hardcode these strings elsewhere.
class Obd2Commands {
  Obd2Commands._();

  // ── Initialization sequence ──────────────────────────────────────────────
  /// Full reset of the ELM327 chip
  static const String reset = 'ATZ';

  /// Turn off command echo (device won't repeat sent bytes)
  static const String echoOff = 'ATE0';

  /// Turn off line-feed characters in responses
  static const String linefeedOff = 'ATL0';

  /// Turn off space characters in responses (compact hex)
  static const String spacesOff = 'ATS0';

  /// Turn off header bytes in responses
  static const String headersOff = 'ATH0';

  /// Auto-detect OBD protocol (0 = auto)
  static const String autoProtocol = 'ATSP0';

  /// Full init sequence to send on every new connection
  static const List<String> initSequence = [
    reset,
    echoOff,
    linefeedOff,
    spacesOff,
    headersOff,
    autoProtocol,
  ];

  // ── Mode 01 — Live data PIDs ─────────────────────────────────────────────
  /// Engine coolant temperature (°C = A - 40)
  static const String coolantTemp = '0105';

  /// Engine load (% = A * 100 / 255)
  static const String engineLoad = '0104';

  /// Engine RPM (RPM = (A*256 + B) / 4)
  static const String rpm = '010C';

  /// Vehicle speed (km/h = A)
  static const String speed = '010D';

  /// Fuel tank level (% = A * 100 / 255)
  static const String fuelLevel = '012F';

  /// Throttle position (% = A * 100 / 255)
  static const String throttlePosition = '0111';

  /// Intake air temperature (°C = A - 40)
  static const String intakeAirTemp = '010F';

  /// Mass air flow rate (g/s = (A*256 + B) / 100)
  static const String massAirFlow = '0110';

  // ── Mode 03 / 04 — Fault codes ───────────────────────────────────────────
  /// Request stored DTCs (Diagnostic Trouble Codes)
  static const String readDtc = '03';

  /// Clear stored DTCs and MIL
  static const String clearDtc = '04';

  // ── Polling set ─────────────────────────────────────────────────────────
  /// PIDs to poll in the main dashboard loop
  static const List<String> dashboardPids = [
    speed,
    rpm,
    coolantTemp,
    fuelLevel,
    engineLoad,
  ];
}
