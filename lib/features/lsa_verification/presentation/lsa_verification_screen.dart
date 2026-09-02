import 'package:habot_lsa_verification/export.dart';

class LsaVerificationScreen extends StatelessWidget {
  final ILsaVerificationRepository? repository;
  final LsaVerificationBloc? bloc;

  const LsaVerificationScreen({
    super.key,
    this.repository,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<LsaVerificationBloc>.value(
        value: bloc!,
        child: const _LsaVerificationView(),
      );
    }

    return BlocProvider<LsaVerificationBloc>(
      create: (_) => LsaVerificationBloc(
        repository: repository ?? LsaVerificationRepository(),
      ),
      child: const _LsaVerificationView(),
    );
  }
}

class _LsaVerificationView extends StatelessWidget {
  const _LsaVerificationView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<LsaVerificationBloc, LsaVerificationState>(
      listener: (context, state) {
        if (state is LsaVerificationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF12B76A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Text(
                'Verification Proven: ${state.response.statusMessage}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        } else if (state is LsaVerificationQuarantined) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFD92D20),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Text(
                'Security Quarantine (${state.exception.quarantineId}): ${state.exception.reason}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 24,
                color: Color(0xFF3157D5),
              ),
              SizedBox(width: 10),
              Text(
                'LSA Verification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: const [ThemeToggleButton(), SizedBox(width: 12)],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'LSA Onboarding Gate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFF8FAFC)
                                  : const Color(0xFF172033),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const VerificationFormCard(),
                          const SizedBox(height: 20),
                          const VerificationStatusCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
