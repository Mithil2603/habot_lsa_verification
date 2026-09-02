import 'package:flutter/material.dart';
import 'widgets/theme_toggle_button.dart';
import 'widgets/verification_form_card.dart';
import 'widgets/verification_status_card.dart';

class LsaVerificationScreen extends StatelessWidget {
  const LsaVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
    );
  }
}
