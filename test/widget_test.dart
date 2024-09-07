// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:work_zone/main.dart';
import 'package:work_zone/pages/buyer/buyer_home.dart';
import 'package:work_zone/pages/seller/seller_home.dart';
import 'package:work_zone/pages/welcome.dart';

void main() {

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    Widget initialScreen;

    if (token != null && token.isNotEmpty) {
      // Check user role (assuming you saved it in SharedPreferences as well)
      String role = prefs.getString('role') ?? '';
      if (role == 'seller') {
        initialScreen = SellerDashboard();
      } else if (role == 'buyer') {
        initialScreen = BuyerHome();
      } else {
        initialScreen = WelcomeScreen(); // Fallback in case of an undefined role
      }
    } else {
      initialScreen = WelcomeScreen();
    }

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(initialScreen: initialScreen,));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
