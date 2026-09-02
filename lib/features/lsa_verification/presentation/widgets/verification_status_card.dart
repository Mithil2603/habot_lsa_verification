import 'package:habot_lsa_verification/export.dart';

class VerificationStatusCard extends StatelessWidget {
  const VerificationStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LsaVerificationBloc, LsaVerificationState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        IconData statusIcon = Icons.info_outline;
        Color statusColor =
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085);
        String title = 'Verification Status';
        String statusText = 'Idle';
        String? detailText;

        if (state is LsaVerificationInProgress) {
          statusIcon = Icons.sync_rounded;
          statusColor = const Color(0xFF3157D5);
          title = 'Data Lineage & Governance';
          statusText = 'Validating and Transmitting...';
          detailText = 'Injecting trace_id & logic_hash headers';
        } else if (state is LsaVerificationSuccess) {
          statusIcon = Icons.check_circle_rounded;
          statusColor = const Color(0xFF12B76A);
          title = 'Verification Status';
          statusText = 'Verified & Lineage Proven (HTTP 200)';
          detailText =
              'ID: ${state.response.verificationId} | Trace: ${state.response.traceId.substring(0, 8)}...';
        } else if (state is LsaVerificationQuarantined) {
          statusIcon = Icons.gpp_bad_rounded;
          statusColor = const Color(0xFFF04438);
          title = 'Security Governance (Fail-Closed)';
          statusText = 'Data Quarantined Locally';
          detailText =
              '${state.exception.quarantineId}: ${state.exception.reason}';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: state is LsaVerificationQuarantined
                  ? const Color(0xFFFDA29B)
                  : state is LsaVerificationSuccess
                      ? const Color(0xFF6CE9A6)
                      : (isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE4E7EC)),
              width: (state is LsaVerificationQuarantined ||
                      state is LsaVerificationSuccess)
                  ? 1.5
                  : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state is LsaVerificationInProgress)
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 2),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF3157D5)),
                        ),
                      ),
                    )
                  else
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 22,
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        if (detailText != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            detailText,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475467),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (state.frictionEventsCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFFEF3F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF475467)
                          : const Color(0xFFFECDCA),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Color(0xFFD92D20),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'UI Friction Logged: ${state.frictionEventsCount} hesitation event(s) (>5s)',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD92D20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
