import 'package:habot_lsa_verification/export.dart';

abstract class LsaVerificationEvent extends Equatable {
  const LsaVerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyAndSubmitPressed extends LsaVerificationEvent {
  final LsaVerificationRequestPayload request;

  const VerifyAndSubmitPressed({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
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
