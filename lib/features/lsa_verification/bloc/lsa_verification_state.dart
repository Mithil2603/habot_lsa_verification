import 'package:habot_lsa_verification/export.dart';

abstract class LsaVerificationState extends Equatable {
  final int frictionEventsCount;

  const LsaVerificationState({this.frictionEventsCount = 0});

  @override
  List<Object?> get props => [frictionEventsCount];
}

class LsaVerificationInitial extends LsaVerificationState {
  const LsaVerificationInitial({super.frictionEventsCount});
}

class LsaVerificationInProgress extends LsaVerificationState {
  const LsaVerificationInProgress({super.frictionEventsCount});
}

class LsaVerificationSuccess extends LsaVerificationState {
  final LsaVerificationResponseModel response;

  const LsaVerificationSuccess({
    required this.response,
    super.frictionEventsCount,
  });

  @override
  List<Object?> get props => [response, frictionEventsCount];
}

class LsaVerificationQuarantined extends LsaVerificationState {
  final SecurityDataQuarantineException exception;

  const LsaVerificationQuarantined({
    required this.exception,
    super.frictionEventsCount,
  });

  @override
  List<Object?> get props => [exception, frictionEventsCount];
}
