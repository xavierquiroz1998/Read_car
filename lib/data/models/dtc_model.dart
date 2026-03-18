import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_boxes.dart';
import '../../core/utils/dtc_decoder.dart';
import '../../domain/entities/dtc_code.dart';

part 'dtc_model.g.dart';

@HiveType(typeId: HiveTypeIds.dtcRecord)
class DtcModel extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String severityLabel;

  @HiveField(3)
  final DateTime detectedAt;

  DtcModel({
    required this.code,
    required this.description,
    required this.severityLabel,
    required this.detectedAt,
  });

  factory DtcModel.fromEntity(DtcCode e) => DtcModel(
        code: e.code,
        description: e.description,
        severityLabel: e.severity.label,
        detectedAt: e.detectedAt,
      );

  DtcCode toEntity() => DtcCode.withDescription(
        code: code,
        description: description,
        severity: DtcSeverity.values.firstWhere(
          (s) => s.label == severityLabel,
          orElse: () => DtcSeverity.unknown,
        ),
        detectedAt: detectedAt,
      );
}
