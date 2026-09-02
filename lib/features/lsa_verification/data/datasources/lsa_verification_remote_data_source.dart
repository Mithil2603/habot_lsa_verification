import 'package:uuid/uuid.dart';
import '../models/lsa_verification_response_model.dart';

/// Abstract contract for remote network execution.
abstract class ILsaVerificationRemoteDataSource {
  /// Sends the verified payload with injected metadata headers to the remote endpoint.
  Future<LsaVerificationResponseModel> postVerification({
    required Map<String, dynamic> payload,
    required Map<String, String> headers,
  });
}

/// Simulated network wrapper simulating production HTTP transport under strict governance.
class MockLsaVerificationRemoteDataSource
    implements ILsaVerificationRemoteDataSource {
  final Duration simulatedNetworkLatency;

  const MockLsaVerificationRemoteDataSource({
    this.simulatedNetworkLatency = const Duration(milliseconds: 300),
  });

  @override
  Future<LsaVerificationResponseModel> postVerification({
    required Map<String, dynamic> payload,
    required Map<String, String> headers,
  }) async {
    // Simulate real-world asynchronous network latency
    if (simulatedNetworkLatency > Duration.zero) {
      await Future<void>.delayed(simulatedNetworkLatency);
    }

    // Strict server-side verification of mandatory metadata headers
    final String? traceId = headers['trace_id'];
    final String? logicHash = headers['logic_hash'];

    if (traceId == null || traceId.trim().isEmpty) {
      throw const FormatException(
        'Server rejected request: Mandatory metadata header "trace_id" is missing.',
      );
    }

    if (logicHash == null || logicHash.trim().isEmpty) {
      throw const FormatException(
        'Server rejected request: Mandatory metadata header "logic_hash" is missing.',
      );
    }

    // Strict server-side check of data lineage
    final dynamic predecessorId = payload['predecessor_id'];
    if (predecessorId == null ||
        predecessorId.toString().trim().isEmpty ||
        predecessorId == 'null') {
      throw const FormatException(
        'Server rejected request: Missing required data lineage predecessor_id.',
      );
    }

    // Build simulated HTTP 200 OK Response
    final String verificationId =
        'VRF-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    final Map<String, dynamic> simulatedResponseBody = {
      'status_code': 200,
      'status_message': 'LSA Verification Request Successfully Processed',
      'verification_id': verificationId,
      'trace_id': traceId,
      'logic_hash': logicHash,
      'verified_at': DateTime.now().toUtc().toIso8601String(),
    };

    return LsaVerificationResponseModel.fromMap(simulatedResponseBody);
  }
}
