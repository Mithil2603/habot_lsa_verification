import 'package:habot_lsa_verification/export.dart';

class LsaVerificationRequestPayload extends Equatable {
  final String? lsaId;
  final String? parentConsentCode;
  final String? predecessorId;

  const LsaVerificationRequestPayload({
    required this.lsaId,
    required this.parentConsentCode,
    required this.predecessorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'lsa_id': lsaId,
      'parent_consent_code': parentConsentCode,
      'predecessor_id': predecessorId,
    };
  }

  factory LsaVerificationRequestPayload.fromMap(Map<String, dynamic> map) {
    return LsaVerificationRequestPayload(
      lsaId: map['lsa_id'] as String?,
      parentConsentCode: map['parent_consent_code'] as String?,
      predecessorId: map['predecessor_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [lsaId, parentConsentCode, predecessorId];
}
