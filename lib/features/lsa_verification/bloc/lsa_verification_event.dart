import 'package:equatable/equatable.dart';

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
