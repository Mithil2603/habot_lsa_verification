import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lsa_verification/features/lsa_verification/data/datasources/lsa_verification_remote_data_source.dart';
import 'package:habot_lsa_verification/features/lsa_verification/data/exceptions/security_data_quarantine_exception.dart';
import 'package:habot_lsa_verification/features/lsa_verification/data/models/lsa_verification_request_payload.dart';
import 'package:habot_lsa_verification/features/lsa_verification/data/models/lsa_verification_response_model.dart';
import 'package:habot_lsa_verification/features/lsa_verification/data/repositories/lsa_verification_repository.dart';

/// Spy remote data source to verify network call interactions and headers.
class SpyLsaVerificationRemoteDataSource
    implements ILsaVerificationRemoteDataSource {
  int callCount = 0;
  Map<String, dynamic>? lastPayload;
  Map<String, String>? lastHeaders;

  @override
  Future<LsaVerificationResponseModel> postVerification({
    required Map<String, dynamic> payload,
    required Map<String, String> headers,
  }) async {
    callCount++;
    lastPayload = payload;
    lastHeaders = headers;

    return LsaVerificationResponseModel(
      statusCode: 200,
      statusMessage: 'Verified successfully',
      verificationId: 'VRF-MOCK-TEST-1',
      traceId: headers['trace_id'] ?? '',
      logicHash: headers['logic_hash'] ?? '',
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
    // -------------------------------------------------------------------------
    // TEST CASE 1: Valid Submission
    // -------------------------------------------------------------------------
    test(
      'Test Case 1 (Valid Submission): Returns HTTP 200/Success after proving metadata headers (trace_id, logic_hash) are injected and predecessor_id is present',
      () async {
        const payload = LsaVerificationRequestPayload(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PARENT-AUTH-999',
          predecessorId: 'PRED-9982-XYZ',
        );

        final response = await repository.verifyLsaSubmission(payload: payload);

        // Assert network call occurred exactly once
        expect(spyRemoteDataSource.callCount, equals(1));

        // Assert response attributes
        expect(response.statusCode, equals(200));
        expect(response.verificationId, isNotEmpty);
        expect(response.traceId, isNotEmpty);
        expect(response.logicHash, isNotEmpty);

        // Verify injected metadata headers
        final injectedHeaders = spyRemoteDataSource.lastHeaders;
        expect(injectedHeaders, isNotNull);
        expect(injectedHeaders!['trace_id'], isNotEmpty);
        expect(injectedHeaders['logic_hash'], isNotEmpty);
        expect(injectedHeaders['logic_hash']!.length, equals(64)); // SHA-256 length

        // Verify lineage is preserved in payload
        final sentPayload = spyRemoteDataSource.lastPayload;
        expect(sentPayload, isNotNull);
        expect(sentPayload!['predecessor_id'], equals('PRED-9982-XYZ'));
        expect(sentPayload['lsa_id'], equals('LSA-7049'));
        expect(sentPayload['parent_consent_code'], equals('PARENT-AUTH-999'));

        // Verify no quarantine records were logged
        expect(repository.quarantinedRecords, isEmpty);
      },
    );

    // -------------------------------------------------------------------------
    // TEST CASE 2: Missing Lineage
    // -------------------------------------------------------------------------
    test(
      'Test Case 2 (Missing Lineage): Halts execution and triggers fail-closed when predecessor_id is null or empty',
      () async {
        const nullPredecessorPayload = LsaVerificationRequestPayload(
          lsaId: 'LSA-7049',
          parentConsentCode: 'PARENT-AUTH-999',
          predecessorId: null, // Null Lineage
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

        // Assert no network call was ever initiated
        expect(spyRemoteDataSource.callCount, equals(0));

        // Assert data was quarantined locally with audit trail
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

    // -------------------------------------------------------------------------
    // TEST CASE 3: Fail-Closed Error State
    // -------------------------------------------------------------------------
    test(
      'Test Case 3 (Fail-Closed Error State): Intercepts invalid payload, halts, quarantines data, and surfaces SecurityDataQuarantineException without network call',
      () async {
        const invalidPayload = LsaVerificationRequestPayload(
          lsaId: '', // Invalid empty LSA ID
          parentConsentCode: '1', // Invalid short consent code
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

        // Assert network submission path was completely aborted
        expect(spyRemoteDataSource.callCount, equals(0));

        // Assert local quarantine log contains the incident
        expect(repository.quarantinedRecords.length, equals(1));
        final quarantinedRecord = repository.quarantinedRecords.first;
        expect(quarantinedRecord.reason, contains('Security Validation Breach'));
        expect(quarantinedRecord.rawPayload['lsa_id'], equals(''));
      },
    );
  });
}
