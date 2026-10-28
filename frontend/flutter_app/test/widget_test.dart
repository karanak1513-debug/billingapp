import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/app.dart';
import 'package:flutter_app/core/constants/app_constants.dart';

void main() {
  testWidgets('Snacks O Clock App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SnacksOClockApp()));

    // Verify app brand is rendered
    expect(find.text(AppConstants.appName), findsOneWidget);
    // Verify navigation tabs
    expect(find.text('Billing POS'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
