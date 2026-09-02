import 'package:equatable/equatable.dart';

/// Exception thrown when security or data lineage validation fails.
///
/// Under strict data governance, any missing, malformed, or unauthorized
/// field causes execution to immediately halt (fail-closed) and quarantine
/// the data locally, aborting all outgoing network calls.
class SecurityDataQuarantineException extends Equatable implements Exception {
  /// Unique identifier of the quarantined security event.
  final String quarantineId;

  /// Specific human-readable reason why the payload was quarantined.
  final String reason;

  /// The timestamp when the quarantine routine was triggered.
  final DateTime timestamp;

  /// The raw payload key-value pairs that were quarantined.
  final Map<String, dynamic> quarantinedData;

  /// The cryptographic checksum of the quarantined payload for audit integrity.
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
