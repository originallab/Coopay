// Smoke test real de CooPayApp — el que vino del template (`MyApp`,
// contador +1) no aplicaba a este proyecto, así que se reemplazó por uno
// que sí verifica algo de esta app: que Bienvenida/Landing carga y muestra
// el nombre CooPay.
import 'package:flutter_test/flutter_test.dart';
import 'package:coopay_app/main.dart';

void main() {
  testWidgets('Landing muestra el nombre CooPay y el CTA de crear cuenta', (WidgetTester tester) async {
    await tester.pumpWidget(const CooPayApp());

    expect(find.text('CooPay'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Ya tengo cuenta'), findsOneWidget);
  });
}
