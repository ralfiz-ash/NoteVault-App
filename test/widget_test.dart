import 'package:flutter_test/flutter_test.dart';

import 'package:notevalult/main.dart';

void main() {
  testWidgets('App launches and shows the NoteVault title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NoteVault'), findsOneWidget);
  });
}
