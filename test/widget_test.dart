import 'package:flutter_test/flutter_test.dart';
import 'package:casvium/main.dart';
import 'package:casvium/services/railway_postgres_service.dart';
import 'package:casvium/data/chore_icons.dart';

void main() {
  testWidgets('Casvium carga el hogar inicial, 30 iconos y mascota Don Mocho',
      (WidgetTester tester) async {
    final store = CasviumStore();
    expect(ChoreIconsCatalog.all.length, 30);
    expect(store.rooms.length, greaterThanOrEqualTo(7));
    expect(store.tasks.isNotEmpty, isTrue);

    await tester.pumpWidget(CasviumApp(store: store));
    expect(find.text('CASVIUM'), findsOneWidget);
    expect(find.textContaining('Don Mocho'), findsWidgets);
  });
}
