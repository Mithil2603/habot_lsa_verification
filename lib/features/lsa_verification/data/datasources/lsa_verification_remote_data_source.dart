import 'package:habot_lsa_verification/export.dart';

abstract class ILsaVerificationRemoteDataSource {
  Future<LsaVerificationResponseModel> postVerification({
    required LsaVerificationRequestPayload payload,
    required LsaVerificationMetadataHeaders headers,
  });
}

class MockLsaVerificationRemoteDataSource
    implements ILsaVerificationRemoteDataSource {
  final Duration simulatedNetworkLatency;

  const MockLsaVerificationRemoteDataSource({
    this.simulatedNetworkLatency = const Duration(milliseconds: 300),
  });

  @override
  Future<LsaVerificationResponseModel> postVerification({
    required LsaVerificationRequestPayload payload,
    required LsaVerificationMetadataHeaders headers,
  }) async {
    if (simulatedNetworkLatency > Duration.zero) {
      await Future<void>.delayed(simulatedNetworkLatency);
    }

    final String traceId = headers.traceId;
    final String logicHash = headers.logicHash;

    if (traceId.trim().isEmpty) {
      throw const FormatException(
        'Server rejected request: Mandatory metadata header "trace_id" is missing.',
      );
    }

    if (logicHash.trim().isEmpty) {
      throw const FormatException(
        'Server rejected request: Mandatory metadata header "logic_hash" is missing.',
      );
    }

    final String? predecessorId = payload.predecessorId;
    if (predecessorId == null ||
        predecessorId.trim().isEmpty ||
        predecessorId == 'null') {
      throw const FormatException(
        'Server rejected request: Missing required data lineage predecessor_id.',
      );
    }

    final String verificationId =
        'VRF-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    return LsaVerificationResponseModel(
      statusCode: 200,
      statusMessage: 'LSA Verification Request Successfully Processed',
      verificationId: verificationId,
      traceId: traceId,
      logicHash: logicHash,
      verifiedAt: DateTime.now().toUtc(),
    );
  }
}
