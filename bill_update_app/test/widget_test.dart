import 'package:flutter_test/flutter_test.dart';
import 'package:bill_update_app/main.dart';

void main() {
  testWidgets('App loads BillUpdateScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const BillApp());
    expect(find.text('Bill Update'), findsOneWidget);
  });
}
