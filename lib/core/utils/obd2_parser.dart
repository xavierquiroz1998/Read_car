/// Stateless OBD2 response parser.
///
/// All methods accept the raw string received from the ELM327 (already
/// stripped of spaces and control characters) and return typed values.
/// They throw [FormatException] on unparseable input — callers should
/// catch and convert to [InvalidResponseFailure].
class Obd2Parser {
  Obd2Parser._();

  // ── Internal helpers ─────────────────────────────────────────────────────

  /// Remove all whitespace, prompt chars ('>') and common ELM artefacts.
  static String _clean(String raw) =>
      raw.replaceAll(RegExp(r'[\s>]'), '').toUpperCase();

  /// Strip the mode+PID echo prefix (e.g. "410D" from "410D3C").
  /// Mode 01 responses start with "41xx" where xx is the PID byte.
  static String _stripHeader(String cleaned, String expectedPid) {
    final pid = expectedPid.toUpperCase();
    // Response header: "41" + last 2 chars of PID (single-byte PID commands)
    final header = '41${pid.substring(2)}';
    if (cleaned.startsWith(header)) {
      return cleaned.substring(header.length);
    }
    return cleaned;
  }

  // ── PID parsers ──────────────────────────────────────────────────────────

  /// PID 010D — Vehicle speed.
  /// Formula: A (km/h)
  static int parseSpeed(String raw) {
    final s = _stripHeader(_clean(raw), '010D');
    if (s.length < 2) throw FormatException('Speed: too short "$raw"');
    return int.parse(s.substring(0, 2), radix: 16);
  }

  /// PID 010C — Engine RPM.
  /// Formula: (A×256 + B) / 4
  static double parseRpm(String raw) {
    final s = _stripHeader(_clean(raw), '010C');
    if (s.length < 4) throw FormatException('RPM: too short "$raw"');
    final a = int.parse(s.substring(0, 2), radix: 16);
    final b = int.parse(s.substring(2, 4), radix: 16);
    return (a * 256 + b) / 4.0;
  }

  /// PID 0105 — Engine coolant temperature.
  /// Formula: A - 40 (°C)
  static int parseCoolantTemp(String raw) {
    final s = _stripHeader(_clean(raw), '0105');
    if (s.length < 2) throw FormatException('Coolant temp: too short "$raw"');
    return int.parse(s.substring(0, 2), radix: 16) - 40;
  }

  /// PID 012F — Fuel tank level.
  /// Formula: A × 100 / 255 (%)
  static double parseFuelLevel(String raw) {
    final s = _stripHeader(_clean(raw), '012F');
    if (s.length < 2) throw FormatException('Fuel level: too short "$raw"');
    final a = int.parse(s.substring(0, 2), radix: 16);
    return a * 100.0 / 255.0;
  }

  /// PID 0104 — Calculated engine load.
  /// Formula: A × 100 / 255 (%)
  static double parseEngineLoad(String raw) {
    final s = _stripHeader(_clean(raw), '0104');
    if (s.length < 2) throw FormatException('Engine load: too short "$raw"');
    final a = int.parse(s.substring(0, 2), radix: 16);
    return a * 100.0 / 255.0;
  }

  // ── DTC parser ───────────────────────────────────────────────────────────

  /// Mode 03 — Parse stored DTC codes from multi-frame response.
  ///
  /// The ELM327 returns "43 XX YY XX YY ..." where each pair of bytes
  /// encodes one DTC. A pair of "0000" means no fault / padding.
  static List<String> parseDtcCodes(String raw) {
    final cleaned = _clean(raw);

    // "NODATA" or "OK" means no DTCs stored
    if (cleaned.contains('NODATA') || cleaned == 'OK' || cleaned.isEmpty) {
      return [];
    }

    // Strip the mode 43 response header ("43")
    String data = cleaned;
    if (data.startsWith('43')) data = data.substring(2);

    final codes = <String>[];

    // Each DTC is 4 hex chars (2 bytes)
    for (int i = 0; i + 4 <= data.length; i += 4) {
      final pair = data.substring(i, i + 4);
      if (pair == '0000') continue; // padding

      final firstNibble = int.parse(pair[0], radix: 16);
      final codeNumber = pair.substring(1); // 3 chars

      // First nibble encodes the DTC category:
      // 0-3 → P, 4-7 → C, 8-B → B, C-F → U
      final category = switch (firstNibble) {
        0 || 1 || 2 || 3 => 'P',
        4 || 5 || 6 || 7 => 'C',
        8 || 9 || 10 || 11 => 'B',
        _ => 'U',
      };

      final digit = (firstNibble % 4).toString();
      codes.add('$category$digit$codeNumber');
    }

    return codes;
  }

  /// Returns true if the response indicates the PID is not supported.
  static bool isNoData(String raw) {
    final c = _clean(raw);
    return c.contains('NODATA') || c.contains('?') || c.isEmpty;
  }
}
