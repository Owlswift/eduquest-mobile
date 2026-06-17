import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App shows login screen when not authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(isLoggedIn: false),
      ),
    );

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('App shows home placeholder when authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(isLoggedIn: true),
      ),
    );

    expect(find.text('Welcome back! You are logged in.'), findsOneWidget);
  });
}