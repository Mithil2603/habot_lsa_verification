import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lsa_verification/export.dart';

void main() {
  testWidgets(
      'LSA Verification Screen smoke test, inputs, submission, and theme toggle',
      (WidgetTester tester) async {
    AppTheme.themeModeNotifier.value = ThemeMode.light;

    await tester.pumpWidget(const MyApp());

    expect(find.text('LSA Verification'), findsOneWidget);
    expect(find.text('LSA Onboarding Gate'), findsOneWidget);
    expect(find.text('Verify & Submit'), findsOneWidget);

    expect(find.text('Idle'), findsOneWidget);

    expect(find.text('Enter LSA ID'), findsOneWidget);
    expect(find.text('Enter consent code'), findsOneWidget);
    expect(find.text('Enter predecessor ID'), findsOneWidget);

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(3));

    await tester.enterText(textFields.at(0), 'LSA-7049');
    await tester.enterText(textFields.at(1), 'AUTH-123');
    await tester.enterText(textFields.at(2), 'PRED-9982-XYZ');
    await tester.pumpAndSettle();

    expect(find.text('LSA-7049'), findsOneWidget);
    expect(find.text('AUTH-123'), findsOneWidget);
    expect(find.text('PRED-9982-XYZ'), findsOneWidget);

    await tester.tap(find.text('Verify & Submit'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Verified & Lineage Proven (HTTP 200)'), findsOneWidget);

    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(AppTheme.themeModeNotifier.value, ThemeMode.dark);
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode_rounded));
    await tester.pumpAndSettle();

    expect(AppTheme.themeModeNotifier.value, ThemeMode.light);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
  });
}
