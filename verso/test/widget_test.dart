import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verso/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VersoApp()));

    // Verify that Verso title is displayed
    expect(find.text('Verso'), findsWidgets);

    // Verify tagline is displayed
    expect(find.text('Where words find their world.'), findsOneWidget);

    // Verify primary CTA is displayed
    expect(find.text('Begin your story'), findsOneWidget);
  });
}
