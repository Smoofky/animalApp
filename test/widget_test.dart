// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:animal_app/utils/Network.dart';
import 'package:animal_app/view/Login%20and%20Register/Login.dart';
import 'package:animal_app/view/Login%20and%20Register/Register.dart';
import 'package:animal_app/view/User/UserStartPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class Mockito extends Mock implements http.Client {}

void main() {
  testWidgets('Make Login screen -> press the button -> find warn text',
      (WidgetTester tester) async {
    Widget makeTestableWidget({Widget? child}) {
      return MaterialApp(
        home: child,
      );
    }
    Login page = const Login();
    await tester.pumpWidget(makeTestableWidget(child: page));
    var elevatedButton = find.byType(ElevatedButton);
    expect(elevatedButton, findsOneWidget);
    await tester.tap(elevatedButton);
    await tester.pump();
    expect(find.text("Please enter email"), findsOneWidget);
    expect(find.text("Please enter password"), findsOneWidget);
  });
  testWidgets('Make Register screen -> press button -> find validation errors',
      (WidgetTester tester) async {
    Widget makeTestableWidget({Widget? child}) {
      return MaterialApp(home: child);
    }

    Register page = const Register();
    await tester.pumpWidget(makeTestableWidget(child: page));
    var elevatedButton = find.byType(ElevatedButton);
    expect(elevatedButton, findsOneWidget);
    await tester.tap(elevatedButton);
    await tester.pumpAndSettle();
    expect(find.text("Required!"), findsNWidgets(2));
    expect(find.text("Please enter login"), findsOneWidget);
    expect(find.text("Please enter email address"), findsOneWidget);
    expect(find.text("Please enter password"), findsOneWidget);
  });
}
