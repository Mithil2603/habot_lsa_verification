import 'package:equatable/equatable.dart';

/// Concrete response model representing the server response after successful verification.
class LsaVerificationResponseModel extends Equatable {
  final int statusCode;
  final String statusMessage;
  final String verificationId;
  final String traceId;
  final String logicHash;
  final DateTime verifiedAt;

  const LsaVerificationResponseModel({
    required this.statusCode,
    required this.statusMessage,
    required this.verificationId,
    required this.traceId,
    required this.logicHash,
    required this.verifiedAt,
  });

  factory LsaVerificationResponseModel.fromMap(Map<String, dynamic> map) {
    return LsaVerificationResponseModel(
      statusCode: (map['status_code'] as num?)?.toInt() ?? 200,
      statusMessage: map['status_message'] as String? ?? 'Verified successfully',
      verificationId: map['verification_id'] as String? ?? '',
      traceId: map['trace_id'] as String? ?? '',
      logicHash: map['logic_hash'] as String? ?? '',
      verifiedAt: map['verified_at'] != null
          ? DateTime.parse(map['verified_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status_code': statusCode,
      'status_message': statusMessage,
      'verification_id': verificationId,
      'trace_id': traceId,
      'logic_hash': logicHash,
      'verified_at': verifiedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        statusCode,
        statusMessage,
        verificationId,
        traceId,
        logicHash,
        verifiedAt,
      ];
}
