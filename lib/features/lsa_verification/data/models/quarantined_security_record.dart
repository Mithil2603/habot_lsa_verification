import 'package:equatable/equatable.dart';

/// Represents a secure, immutable record of quarantined data stored locally
/// for governance audit trails when a fail-closed routine is triggered.
class QuarantinedSecurityRecord extends Equatable {
  final String quarantineId;
  final String reason;
  final Map<String, dynamic> rawPayload;
  final String sha256Checksum;
  final DateTime quarantinedAt;

  const QuarantinedSecurityRecord({
    required this.quarantineId,
    required this.reason,
    required this.rawPayload,
    required this.sha256Checksum,
    required this.quarantinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'quarantine_id': quarantineId,
      'reason': reason,
      'raw_payload': rawPayload,
      'sha256_checksum': sha256Checksum,
      'quarantined_at': quarantinedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        quarantineId,
        reason,
        rawPayload,
        sha256Checksum,
        quarantinedAt,
      ];
}
