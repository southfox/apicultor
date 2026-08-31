import 'package:apicultor/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el apiario y las colmenas iniciales', (tester) async {
    await tester.pumpWidget(const ApicultorApp());

    expect(find.text('Apiario Campo Norte'), findsOneWidget);
    expect(find.text('Mis colmenas'), findsOneWidget);
    expect(find.text('Colmena 1'), findsOneWidget);
  });
}
