import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_finanzapp/main.dart';

void main() {
  testWidgets('Renderiza HomeScreen con elementos requeridos del Dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MiFinanzappApp());
    // Permitir resolución de Future en HomeScreen
    await tester.pumpAndSettle();

    // Verificación de título
    expect(find.text('MiFinanzapp'), findsOneWidget);

    // Verificación de tarjetas de saldo requeridas
    expect(find.text('Saldo Total Disponible'), findsOneWidget);
    expect(find.text('Banco'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);

    // Verificación de resumen de totales requerido
    expect(find.text('Ingresos'), findsOneWidget);
    expect(find.text('Gastos'), findsOneWidget);
    expect(find.text('G. Hormiga'), findsOneWidget);

    // Verificación de acciones principales
    expect(find.text('Agregar ingreso'), findsOneWidget);
    expect(find.text('Agregar gasto'), findsOneWidget);

    // Verificación de sección de movimientos recientes
    expect(find.text('Movimientos recientes'), findsOneWidget);
  });
}
