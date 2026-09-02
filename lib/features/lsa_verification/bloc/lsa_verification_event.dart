import 'package:habot_lsa_verification/export.dart';

abstract class LsaVerificationEvent extends Equatable {
  const LsaVerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyAndSubmitPressed extends LsaVerificationEvent {
  final String lsaId;
  final String parentConsentCode;
  final String predecessorId;

  const VerifyAndSubmitPressed({
    required this.lsaId,
    required this.parentConsentCode,
    required this.predecessorId,
  });

  @override
  List<Object?> get props => [lsaId, parentConsentCode, predecessorId];
}

class FrictionEventDetected extends LsaVerificationEvent {
  final String fieldName;
  final int stallDurationSeconds;
  final DateTime detectedAt;

  FrictionEventDetected({
    required this.fieldName,
    this.stallDurationSeconds = 5,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now().toUtc();

  @override
  List<Object?> get props => [fieldName, stallDurationSeconds, detectedAt];
}

class ResetVerificationState extends LsaVerificationEvent {
  const ResetVerificationState();
}
