import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_finanzapp/models/movimiento.dart';
import 'package:mi_finanzapp/screens/formulario_movimiento_screen.dart';

void main() {
  testWidgets('FormularioMovimientoScreen para ingreso muestra campos y valida monto', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FormularioMovimientoScreen(tipo: TipoMovimiento.ingreso),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Agregar Ingreso'), findsOneWidget);
    expect(find.text('Monto (\$)'), findsOneWidget);
    expect(find.text('Descripción'), findsOneWidget);
    expect(find.text('¿Dónde ocurrió el movimiento?'), findsOneWidget);
    expect(find.text('Banco'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);
    expect(find.text('Categoría'), findsOneWidget);
    expect(find.text('Fecha'), findsOneWidget);

    // En ingreso NO debe aparecer switch de gasto hormiga
    expect(find.text('¿Es gasto hormiga?'), findsNothing);

    // Intentar guardar con campos vacíos activa validaciones
    final botonGuardar = find.text('Guardar Ingreso');
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un monto'), findsOneWidget);
    expect(find.text('Ingresa una descripción'), findsOneWidget);
  });

  testWidgets('FormularioMovimientoScreen para gasto incluye switch de gasto hormiga y valida campos', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FormularioMovimientoScreen(tipo: TipoMovimiento.gasto),
      ),
    );
    await tester.pumpAndSettle();

    // Encabezado de gasto
    expect(find.text('Agregar Gasto'), findsOneWidget);

    // Switch de gasto hormiga DEBE estar presente
    expect(find.text('¿Es gasto hormiga?'), findsOneWidget);
    expect(find.text('Compra pequeña cotidiana (café, snack, etc.)'), findsOneWidget);

    // Verificar categorías de gasto (por defecto primera categoría es Comida)
    expect(find.text('Comida'), findsOneWidget);

    // Probar el toggle del switch manual de gasto hormiga
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    Switch switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, isFalse); // Inicia desmarcado

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, isTrue); // Ahora está marcado como hormiga

    // Validar monto vacío
    final botonGuardar = find.text('Guardar Gasto');
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un monto'), findsOneWidget);
    expect(find.text('Ingresa una descripción'), findsOneWidget);
  });

  testWidgets('Validación de monto mayor que cero en formulario', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FormularioMovimientoScreen(tipo: TipoMovimiento.gasto),
      ),
    );
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    // Ingresar 0 como monto
    await tester.enterText(textFields.first, '0');
    // Ingresar descripción válida
    await tester.enterText(textFields.last, 'Prueba de gasto cero');

    final botonGuardar = find.text('Guardar Gasto');
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(find.text('El monto debe ser mayor que cero'), findsOneWidget);
  });
}
