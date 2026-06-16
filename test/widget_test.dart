import 'package:flutter_test/flutter_test.dart';

import 'package:student_mobile/main.dart';

void main() {
  testWidgets('shows the ReadBloom login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('welcome little one!'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
  });
}
