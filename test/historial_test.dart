import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_finanzapp/screens/historial_screen.dart';

void main() {
  testWidgets('HistorialScreen renderiza filtros requeridos y estado vacío inicial', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HistorialScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verificación de encabezado
    expect(find.text('Historial'), findsOneWidget);

    // Verificación de chips de filtro requeridos
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Ingresos'), findsOneWidget);
    expect(find.text('Gastos'), findsOneWidget);
    expect(find.text('Gastos hormiga 🐜'), findsOneWidget);
    expect(find.text('Banco'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);

    // Estado vacío inicial
    expect(find.text('Sin movimientos'), findsOneWidget);
    expect(find.text('No hay movimientos para el filtro seleccionado.'), findsOneWidget);

    // Tocar el filtro de "Gastos"
    await tester.tap(find.text('Gastos'));
    await tester.pumpAndSettle();

    // El filtro sigue activo y la lista se actualiza
    expect(find.text('Gastos'), findsOneWidget);
  });
}
