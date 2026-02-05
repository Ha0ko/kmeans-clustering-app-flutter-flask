// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:kmeans_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KMeansApp());

    // Verify that the app starts with the data input screen
    expect(find.text('Customer Segmentation Tool'), findsOneWidget);
    expect(find.text('Next Step'), findsOneWidget);
  });
}
