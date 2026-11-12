import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:casvium/main.dart';
import 'package:casvium/models/models.dart';
import 'package:casvium/widgets/custom_components.dart';
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

  testWidgets('Crear una tarea y editar su periodicidad desde la ficha',
      (tester) async {
    final store = CasviumStore();
    await tester.pumpWidget(CasviumApp(store: store));

    await _openTab(tester, 'broom_dustpan');
    expect(find.byType(GridView), findsNothing);
    await tester.tap(find.text('+ Nueva Tarea'));
    await _finishTransition(tester);

    final page = find.ancestor(
      of: find.byType(AppBar),
      matching: find.byType(Scaffold),
    );
    expect(find.text('Nueva tarea'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(CasviumFloatingDock), findsNothing);
    final fields = find.descendant(of: page, matching: find.byType(TextField));
    await tester.enterText(fields.first, 'Limpiar horno');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _selectFrequency(tester, TaskFrequency.monthly);

    final formScroll = find
        .descendant(of: page, matching: find.byType(Scrollable))
        .first;
    final ovenIcon = find.byTooltip('Horno');
    await tester.scrollUntilVisible(ovenIcon, 250, scrollable: formScroll);
    await Scrollable.ensureVisible(tester.element(ovenIcon), alignment: 0.5);
    await tester.pump();
    expect(find.byTooltip('Plancha'), findsOneWidget);
    expect(find.byTooltip('Regadera'), findsOneWidget);
    for (final icon in ChoreIconsCatalog.all) {
      final label = find.descendant(of: page, matching: find.text(icon.label));
      final paragraph = tester.renderObject<RenderParagraph>(label);
      expect(paragraph.didExceedMaxLines, isFalse, reason: icon.label);
    }
    await tester.tap(ovenIcon);
    await tester.pump();

    final save = find.text('Guardar Tarea en el Hogar');
    await tester.scrollUntilVisible(save, 250, scrollable: formScroll);
    await Scrollable.ensureVisible(tester.element(save), alignment: 0.5);
    await tester.pump();
    await tester.tap(save);
    await _finishTransition(tester);

    expect(find.text('Nueva tarea'), findsNothing);
    expect(find.text('+ Nueva Tarea'), findsOneWidget);
    expect(store.currentTasks.first.title, 'Limpiar horno');
    expect(store.currentTasks.first.iconKey, 'oven_sparkle');
    expect(store.currentTasks.first.frequency, TaskFrequency.monthly);

    final edit = find.byTooltip('Editar periodicidad de Limpiar horno');
    await tester.scrollUntilVisible(
      edit,
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(tester.element(edit), alignment: 0.5);
    await tester.pump();
    await tester.tap(edit);
    await _finishTransition(tester);
    await _selectFrequency(tester, TaskFrequency.none);
    await tester.tap(find.text('Guardar periodicidad'));
    await _finishTransition(tester);

    expect(store.currentTasks.first.frequency, TaskFrequency.none);
    expect(find.text('Sin periodicidad'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Cancelar y Volver descartan el borrador y regresan a Tareas',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final store = CasviumStore();
    final taskCount = store.currentTasks.length;
    await tester.pumpWidget(CasviumApp(store: store));
    await _openTab(tester, 'broom_dustpan');

    for (final exit in [find.text('Cancelar'), find.byTooltip('Volver')]) {
      await tester.tap(find.text('+ Nueva Tarea'));
      await _finishTransition(tester);

      tester.view.physicalSize = const Size(390, 844);
      await tester.pump();
      expect(exit.hitTestable(), findsOneWidget);
      final title = find.byType(TextField).first;
      expect(tester.widget<TextField>(title).controller!.text, isEmpty);
      await tester.enterText(title, 'Borrador');

      await tester.tap(exit);
      tester.view.physicalSize = const Size(800, 600);
      await _finishTransition(tester);

      expect(find.text('Tareas ($taskCount)'), findsOneWidget);
      expect(find.text('Nueva tarea'), findsNothing);
      expect(store.currentTasks.length, taskCount);
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('El informe actualiza el aviso al registrar una sesión',
      (tester) async {
    final store = CasviumStore();
    final now = DateTime.now();
    store.tasks
      ..clear()
      ..add(ChoreTask(
        id: 'task-deadline',
        householdId: store.currentHousehold.id,
        title: 'Limpiar horno',
        description: '',
        iconKey: 'oven_sparkle',
        roomIds: [store.currentRooms.first.id],
        estimatedMinutes: 20,
        frequency: TaskFrequency.daily,
        createdAt: DateTime(now.year, now.month, now.day - 4),
      ));
    store.sessions.clear();
    await tester.pumpWidget(CasviumApp(store: store));

    expect(find.text('1 tarea vencida'), findsOneWidget);
    await tester.tap(find.text('Ver calendario de tareas'));
    await _finishTransition(tester);
    expect(find.text('1 vencida · 0 para hoy · 0 próximas'), findsOneWidget);
    expect(find.textContaining('Venció el'), findsOneWidget);

    await tester.tap(find.byTooltip('Registrar sesión de Limpiar horno'));
    await _finishTransition(tester);
    final save = find.text('Guardar Sesión de Trabajo');
    await tester.scrollUntilVisible(
      save,
      300,
      scrollable: find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(save);
    await _finishTransition(tester);

    expect(store.currentSessions.single.taskId, 'task-deadline');
    expect(find.text('0 vencidas · 0 para hoy · 1 próxima'), findsOneWidget);
    expect(find.textContaining('Próxima el'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _openTab(WidgetTester tester, String iconKey) async {
  await tester.tap(find.descendant(
    of: find.byType(CasviumFloatingDock),
    matching: find.byWidgetPredicate(
      (widget) => widget is ChoreCustomIcon && widget.iconKey == iconKey,
    ),
  ));
  await _finishTransition(tester);
}

Future<void> _selectFrequency(
  WidgetTester tester,
  TaskFrequency frequency,
) async {
  await tester.tap(find.byType(DropdownButtonFormField<TaskFrequency>));
  await _finishTransition(tester);
  await tester.tap(find.text(frequency.label).last);
  await _finishTransition(tester);
}

Future<void> _finishTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}
