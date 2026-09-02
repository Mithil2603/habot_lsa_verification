import 'package:habot_lsa_verification/export.dart';

abstract class ILsaVerificationRepository {
  Future<LsaVerificationResponseModel> verifyLsaSubmission({
    required LsaVerificationRequestPayload payload,
  });

  List<QuarantinedSecurityRecord> get quarantinedRecords;
}

class LsaVerificationRepository implements ILsaVerificationRepository {
  final ILsaVerificationRemoteDataSource _remoteDataSource;
  final Uuid _uuidGenerator;

  final List<QuarantinedSecurityRecord> _quarantineAuditLog = [];

  LsaVerificationRepository({
    ILsaVerificationRemoteDataSource? remoteDataSource,
    Uuid? uuidGenerator,
  })  : _remoteDataSource =
            remoteDataSource ?? const MockLsaVerificationRemoteDataSource(),
        _uuidGenerator = uuidGenerator ?? const Uuid();

  @override
  List<QuarantinedSecurityRecord> get quarantinedRecords =>
      List<QuarantinedSecurityRecord>.unmodifiable(_quarantineAuditLog);

  void clearQuarantineLog() {
    _quarantineAuditLog.clear();
  }

  @override
  Future<LsaVerificationResponseModel> verifyLsaSubmission({
    required LsaVerificationRequestPayload payload,
  }) async {
    final String? predecessorIdentifier = payload.predecessorId;
    if (predecessorIdentifier == null ||
        predecessorIdentifier.trim().isEmpty ||
        predecessorIdentifier == 'null') {
      _executeFailClosedRoutine(
        reason:
            'Strict Data Lineage Violation: Mandatory "predecessor_id" is null or empty. Lineage unbroken assertion failed.',
        payload: payload,
      );
    }

    final String? lsaIdentifier = payload.lsaId;
    if (lsaIdentifier == null ||
        lsaIdentifier.trim().isEmpty ||
        lsaIdentifier == 'null') {
      _executeFailClosedRoutine(
        reason:
            'Security Validation Breach: Mandatory "lsa_id" is null or empty.',
        payload: payload,
      );
    }

    final String? consentCode = payload.parentConsentCode;
    if (consentCode == null ||
        consentCode.trim().isEmpty ||
        consentCode == 'null') {
      _executeFailClosedRoutine(
        reason:
            'Security Validation Breach: Mandatory "parent_consent_code" is null or empty.',
        payload: payload,
      );
    }

    if (consentCode.trim().length < 3) {
      _executeFailClosedRoutine(
        reason:
            'Security Validation Breach: "parent_consent_code" fails minimum entropy requirement (length < 3).',
        payload: payload,
      );
    }

    final String dynamicTraceId = _uuidGenerator.v4();

    final String dynamicLogicHash = _computeComplianceLogicHash(
      payload: payload,
      traceId: dynamicTraceId,
    );

    final LsaVerificationMetadataHeaders outboundHeaders =
        LsaVerificationMetadataHeaders(
      traceId: dynamicTraceId,
      logicHash: dynamicLogicHash,
    );

    try {
      final LsaVerificationResponseModel response =
          await _remoteDataSource.postVerification(
        payload: payload,
        headers: outboundHeaders,
      );
      return response;
    } catch (unexpectedException) {
      _executeFailClosedRoutine(
        reason: 'Remote Transport Exception: ${unexpectedException.toString()}',
        payload: payload,
      );
    }
  }

  String _computeComplianceLogicHash({
    required LsaVerificationRequestPayload payload,
    required String traceId,
  }) {
    const String governanceRuleVersion =
        'HABOT_COMPLIANCE_GOVERNANCE_SPEC_V1.0';
    final String serializedPayload = jsonEncode(payload.toMap());
    final String signatureInput =
        '$governanceRuleVersion:$traceId:$serializedPayload';

    final Digest hashDigest = sha256.convert(utf8.encode(signatureInput));
    return hashDigest.toString();
  }

  Never _executeFailClosedRoutine({
    required String reason,
    required LsaVerificationRequestPayload payload,
  }) {
    final String quarantineIdentifier =
        'QRNT-${_uuidGenerator.v4().substring(0, 8).toUpperCase()}';
    final Map<String, dynamic> rawPayload = payload.toMap();
    final String serializedData = jsonEncode(rawPayload);
    final String payloadChecksum =
        sha256.convert(utf8.encode(serializedData)).toString();

    final QuarantinedSecurityRecord quarantineRecord =
        QuarantinedSecurityRecord(
      quarantineId: quarantineIdentifier,
      reason: reason,
      rawPayload: rawPayload,
      sha256Checksum: payloadChecksum,
      quarantinedAt: DateTime.now().toUtc(),
    );

    _quarantineAuditLog.add(quarantineRecord);

    throw SecurityDataQuarantineException(
      quarantineId: quarantineIdentifier,
      reason: reason,
      quarantinedData: rawPayload,
      integrityChecksum: payloadChecksum,
      timestamp: quarantineRecord.quarantinedAt,
    );
  }
}
