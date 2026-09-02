import 'package:habot_lsa_verification/export.dart';

class SecurityDataQuarantineException extends Equatable implements Exception {
  final String quarantineId;
  final String reason;
  final DateTime timestamp;
  final Map<String, dynamic> quarantinedData;
  final String integrityChecksum;

  SecurityDataQuarantineException({
    required this.quarantineId,
    required this.reason,
    required this.quarantinedData,
    required this.integrityChecksum,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [
        quarantineId,
        reason,
        timestamp,
        quarantinedData,
        integrityChecksum,
      ];

  @override
  String toString() {
    return 'SecurityDataQuarantineException('
        'quarantineId: $quarantineId, '
        'reason: $reason, '
        'timestamp: ${timestamp.toIso8601String()}, '
        'integrityChecksum: $integrityChecksum)';
  }
}
