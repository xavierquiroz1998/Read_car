import 'package:equatable/equatable.dart';
import '../../core/utils/dtc_decoder.dart';

/// A single Diagnostic Trouble Code with its decoded description.
class DtcCode extends Equatable {
  final String code;
  final String description;
  final DtcSeverity severity;
  final DateTime detectedAt;

  DtcCode({
    required this.code,
    required this.detectedAt,
  })  : description = DtcDecoder.describe(code),
        severity = DtcDecoder.severity(code);

  const DtcCode.withDescription({
    required this.code,
    required this.description,
    required this.severity,
    required this.detectedAt,
  });

  @override
  List<Object?> get props => [code, detectedAt];
}
