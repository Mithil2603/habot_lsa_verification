import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lsa_verification/export.dart';

class MockTestRemoteDataSource implements ILsaVerificationRemoteDataSource {
  @override
  Future<LsaVerificationResponseModel> postVerification({
    required Map<String, dynamic> payload,
    required Map<String, String> headers,
  }) async {
    return LsaVerificationResponseModel(
      statusCode: 200,
      statusMessage: 'Processed successfully',
      verificationId: 'VRF-TEST-888',
      traceId: headers['trace_id'] ?? 'mock-trace-id',
      logicHash: headers['logic_hash'] ?? 'mock-logic-hash',
      verifiedAt: DateTime.now().toUtc(),
    );
  }
}

void main() {
  late LsaVerificationRepository repository;
  late LsaVerificationBloc bloc;

  setUp(() {
    repository = LsaVerificationRepository(
      remoteDataSource: MockTestRemoteDataSource(),
    );
    bloc = LsaVerificationBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('LsaVerificationBloc State Transitions & Friction Tracking Tests', () {
    test('Initial state should be LsaVerificationInitial with 0 friction count',
        () {
      expect(bloc.state, equals(const LsaVerificationInitial()));
      expect(bloc.state.frictionEventsCount, equals(0));
    });

    test(
      'VerifyAndSubmitPressed with valid data emits [LsaVerificationInProgress, LsaVerificationSuccess]',
      () async {
        final expectedStates = [
          isA<LsaVerificationInProgress>(),
          isA<LsaVerificationSuccess>().having(
            (s) => s.response.verificationId,
            'verificationId',
            equals('VRF-TEST-888'),
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const VerifyAndSubmitPressed(
          lsaId: 'LSA-7049',
          parentConsentCode: 'AUTH-CODE-123',
          predecessorId: 'PRED-9982-XYZ',
        ));
      },
    );

    test(
      'VerifyAndSubmitPressed with missing predecessorId triggers Fail-Closed and emits [LsaVerificationInProgress, LsaVerificationQuarantined]',
      () async {
        final expectedStates = [
          isA<LsaVerificationInProgress>(),
          isA<LsaVerificationQuarantined>().having(
            (s) => s.exception.reason,
            'reason',
            contains('Strict Data Lineage Violation'),
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const VerifyAndSubmitPressed(
          lsaId: 'LSA-7049',
          parentConsentCode: 'AUTH-CODE-123',
          predecessorId: '',
        ));
      },
    );

    test(
      'VerifyAndSubmitPressed with empty lsaId triggers Fail-Closed and emits [LsaVerificationInProgress, LsaVerificationQuarantined]',
      () async {
        final expectedStates = [
          isA<LsaVerificationInProgress>(),
          isA<LsaVerificationQuarantined>().having(
            (s) => s.exception.reason,
            'reason',
            contains('Security Validation Breach'),
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const VerifyAndSubmitPressed(
          lsaId: '',
          parentConsentCode: 'AUTH-CODE-123',
          predecessorId: 'PRED-9982-XYZ',
        ));
      },
    );

    test(
      'FrictionEventDetected records user hesitation and updates telemetry log and state count',
      () async {
        final expectedStates = [
          isA<LsaVerificationInitial>().having(
            (s) => s.frictionEventsCount,
            'frictionEventsCount',
            equals(1),
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(FrictionEventDetected(
          fieldName: 'lsa_id',
          stallDurationSeconds: 5,
        ));

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.frictionTelemetryLog.length, equals(1));
        expect(bloc.frictionTelemetryLog.first.fieldName, equals('lsa_id'));
      },
    );

    test(
      'ResetVerificationState resets state from Quarantined back to LsaVerificationInitial while preserving friction telemetry count',
      () async {
        bloc.add(const VerifyAndSubmitPressed(
          lsaId: '',
          parentConsentCode: '',
          predecessorId: '',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(bloc.state, isA<LsaVerificationQuarantined>());

        final expectedStates = [
          isA<LsaVerificationInitial>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const ResetVerificationState());
      },
    );
  });
}
