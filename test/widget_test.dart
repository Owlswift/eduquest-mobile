import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';

void main() {
  testWidgets('App starts at splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EduQuestApp());
    await tester.pump();

    expect(find.text('Splash Screen'), findsOneWidget);
  });
}