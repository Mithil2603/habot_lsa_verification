import 'package:habot_lsa_verification/export.dart';

class LsaVerificationBloc
    extends Bloc<LsaVerificationEvent, LsaVerificationState> {
  final ILsaVerificationRepository _repository;

  final List<FrictionEventDetected> _frictionTelemetryLog = [];

  List<FrictionEventDetected> get frictionTelemetryLog =>
      List<FrictionEventDetected>.unmodifiable(_frictionTelemetryLog);

  LsaVerificationBloc({
    required ILsaVerificationRepository repository,
  })  : _repository = repository,
        super(const LsaVerificationInitial()) {
    on<VerifyAndSubmitPressed>(_onVerifyAndSubmitPressed);
    on<FrictionEventDetected>(_onFrictionEventDetected);
    on<ResetVerificationState>(_onResetVerificationState);
  }

  Future<void> _onVerifyAndSubmitPressed(
    VerifyAndSubmitPressed event,
    Emitter<LsaVerificationState> emit,
  ) async {
    emit(LsaVerificationInProgress(
      frictionEventsCount: _frictionTelemetryLog.length,
    ));

    final LsaVerificationRequestPayload request =
        LsaVerificationRequestPayload(
      lsaId: event.lsaId,
      parentConsentCode: event.parentConsentCode,
      predecessorId: event.predecessorId,
    );

    try {
      final LsaVerificationResponseModel response =
          await _repository.verifyLsaSubmission(payload: request);

      emit(LsaVerificationSuccess(
        response: response,
        frictionEventsCount: _frictionTelemetryLog.length,
      ));
    } on SecurityDataQuarantineException catch (quarantineException) {
      emit(LsaVerificationQuarantined(
        exception: quarantineException,
        frictionEventsCount: _frictionTelemetryLog.length,
      ));
    } catch (unhandledError) {
      final Map<String, dynamic> quarantinedPayload = request.toMap();
      final String checksum = sha256
          .convert(utf8.encode(jsonEncode(quarantinedPayload)))
          .toString();

      final SecurityDataQuarantineException failClosedException =
          SecurityDataQuarantineException(
        quarantineId: 'QRNT-FALLBACK-ERR',
        reason:
            'Unhandled runtime failure quarantined under fail-closed governance: ${unhandledError.toString()}',
        quarantinedData: quarantinedPayload,
        integrityChecksum: checksum,
      );

      emit(LsaVerificationQuarantined(
        exception: failClosedException,
        frictionEventsCount: _frictionTelemetryLog.length,
      ));
    }
  }

  void _onFrictionEventDetected(
    FrictionEventDetected event,
    Emitter<LsaVerificationState> emit,
  ) {
    _frictionTelemetryLog.add(event);

    final int updatedFrictionCount = _frictionTelemetryLog.length;

    if (state is LsaVerificationInitial) {
      emit(LsaVerificationInitial(frictionEventsCount: updatedFrictionCount));
    } else if (state is LsaVerificationInProgress) {
      emit(LsaVerificationInProgress(frictionEventsCount: updatedFrictionCount));
    } else if (state is LsaVerificationSuccess) {
      final currentState = state as LsaVerificationSuccess;
      emit(LsaVerificationSuccess(
        response: currentState.response,
        frictionEventsCount: updatedFrictionCount,
      ));
    } else if (state is LsaVerificationQuarantined) {
      final currentState = state as LsaVerificationQuarantined;
      emit(LsaVerificationQuarantined(
        exception: currentState.exception,
        frictionEventsCount: updatedFrictionCount,
      ));
    }
  }

  void _onResetVerificationState(
    ResetVerificationState event,
    Emitter<LsaVerificationState> emit,
  ) {
    emit(LsaVerificationInitial(
      frictionEventsCount: _frictionTelemetryLog.length,
    ));
  }
}
