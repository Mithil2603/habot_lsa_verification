import 'package:habot_lsa_verification/export.dart';

class LsaVerificationMetadataHeaders extends Equatable {
  final String traceId;
  final String logicHash;
  final String contentType;
  final String accept;

  const LsaVerificationMetadataHeaders({
    required this.traceId,
    required this.logicHash,
    this.contentType = 'application/json',
    this.accept = 'application/json',
  });

  Map<String, String> toMap() {
    return {
      'Content-Type': contentType,
      'Accept': accept,
      'trace_id': traceId,
      'logic_hash': logicHash,
    };
  }

  factory LsaVerificationMetadataHeaders.fromMap(Map<String, String> map) {
    return LsaVerificationMetadataHeaders(
      traceId: map['trace_id'] ?? '',
      logicHash: map['logic_hash'] ?? '',
      contentType: map['Content-Type'] ?? 'application/json',
      accept: map['Accept'] ?? 'application/json',
    );
  }

  @override
  List<Object?> get props => [traceId, logicHash, contentType, accept];
}
