import 'package:flutter_test/flutter_test.dart';
import 'package:kwanpa_susu/main.dart';

void main() {
  testWidgets('App loads GetStartedScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KwanpaSusuApp());
    expect(find.text('Kwanpa Susu'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
