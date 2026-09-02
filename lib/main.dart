import 'package:flutter/material.dart';
import 'package:habot_lsa_verification/core/app_theme.dart';
import 'package:habot_lsa_verification/features/lsa_verification/presentation/lsa_verification_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LSA Verification',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const LsaVerificationScreen(),
        );
      },
    );
  }
}
