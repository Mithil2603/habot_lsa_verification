import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lsa_verification/export.dart';

class SpyLsaVerificationRemoteDataSource
    implements ILsaVerificationRemoteDataSource {
  int callCount = 0;
  LsaVerificationRequestPayload? lastPayload;
  LsaVerificationMetadataHeaders? lastHeaders;

  @override
  Future<LsaVerificationResponseModel> postVerification({
    required LsaVerificationRequestPayload payload,
    required LsaVerificationMetadataHeaders headers,
  }) async {
    callCount++;
    lastPayload = payload;
    lastHeaders = headers;

    return LsaVerificationResponseModel(
      statusCode: 200,
      statusMessage: 'Verified successfully',
      verificationId: 'VRF-MOCK-TEST-1',
      traceId: headers.traceId,
      logicHash: headers.logicHash,
      verifiedAt: DateTime.now().toUtc(),
    );
  }
}

void main() {
  late SpyLsaVerificationRemoteDataSource spyRemoteDataSource;
  late LsaVerificationRepository repository;

  setUp(() {
    spyRemoteDataSource = SpyLsaVerificationRemoteDataSource();
    repository = LsaVerificationRepository(
      remoteDataSource: spyRemoteDataSource,
    );
  });

  group('LsaVerificationRepository - Strict Data Governance Tests', () {
    test(
      'Test Case 1 (Valid Submission): Returns HTTP 200/Success after proving metadata headers (trace_id, logic_hash) are injected and predecessor_id is present',
      () async {
        const payload = LsaVerificationRequestPayload(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PARENT-AUTH-999',
          predecessorId: 'PRED-9982-XYZ',
        );

        final response = await repository.verifyLsaSubmission(payload: payload);

        expect(spyRemoteDataSource.callCount, equals(1));
        expect(response.statusCode, equals(200));
        expect(response.verificationId, isNotEmpty);
        expect(response.traceId, isNotEmpty);
        expect(response.logicHash, isNotEmpty);

        final injectedHeaders = spyRemoteDataSource.lastHeaders;
        expect(injectedHeaders, isNotNull);
        expect(injectedHeaders!.traceId, isNotEmpty);
        expect(injectedHeaders.logicHash, isNotEmpty);
        expect(injectedHeaders.logicHash.length, equals(64));

        final sentPayload = spyRemoteDataSource.lastPayload;
        expect(sentPayload, isNotNull);
        expect(sentPayload!.predecessorId, equals('PRED-9982-XYZ'));
        expect(sentPayload.lsaId, equals('LSA-7049'));
        expect(sentPayload.parentConsentCode, equals('PARENT-AUTH-999'));

        expect(repository.quarantinedRecords, isEmpty);
      },
    );

    test(
      'Test Case 2 (Missing Lineage): Halts execution and triggers fail-closed when predecessor_id is null or empty',
      () async {
        const nullPredecessorPayload = LsaVerificationRequestPayload(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PARENT-AUTH-999',
          predecessorId: null,
        );

        expect(
          () => repository.verifyLsaSubmission(payload: nullPredecessorPayload),
          throwsA(
            isA<SecurityDataQuarantineException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  contains('Strict Data Lineage Violation'),
                )
                .having(
                  (e) => e.quarantinedData['predecessor_id'],
                  'predecessor_id',
                  isNull,
                ),
          ),
        );

        expect(spyRemoteDataSource.callCount, equals(0));
        expect(repository.quarantinedRecords.length, equals(1));
        expect(
          repository.quarantinedRecords.first.reason,
          contains('Strict Data Lineage Violation'),
        );
        expect(
          repository.quarantinedRecords.first.sha256Checksum,
          isNotEmpty,
        );
      },
    );

    test(
      'Test Case 3 (Fail-Closed Error State): Intercepts invalid payload, halts, quarantines data, and surfaces SecurityDataQuarantineException without network call',
      () async {
        const invalidPayload = LsaVerificationRequestPayload(
          lsaId: '',
          parentConsentCode: '1',
          predecessorId: 'PRED-VALID-001',
        );

        expect(
          () => repository.verifyLsaSubmission(payload: invalidPayload),
          throwsA(
            isA<SecurityDataQuarantineException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  contains('Security Validation Breach'),
                )
                .having(
                  (e) => e.quarantineId,
                  'quarantineId',
                  startsWith('QRNT-'),
                ),
          ),
        );

        expect(spyRemoteDataSource.callCount, equals(0));
        expect(repository.quarantinedRecords.length, equals(1));
        final quarantinedRecord = repository.quarantinedRecords.first;
        expect(quarantinedRecord.reason, contains('Security Validation Breach'));
        expect(quarantinedRecord.rawPayload['lsa_id'], equals(''));
      },
    );
  });
}
