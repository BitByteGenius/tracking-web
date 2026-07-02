// Widget tests for Live Tracking System.
// The auto-generated counter smoke test has been replaced because this app
// uses a custom entry point (LiveTrackingApp) and has no counter widget.
// Integration tests for Check In / Check Out are run manually against the backend.

import 'package:flutter_test/flutter_test.dart';
import 'package:live_tracking_web/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const LiveTrackingApp());
    // The splash screen should be the first widget rendered.
    expect(find.byType(LiveTrackingApp), findsOneWidget);
  });
}
