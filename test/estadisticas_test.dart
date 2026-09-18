import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_finanzapp/screens/estadisticas_screen.dart';

void main() {
  group('EstadisticasScreen', () {
    Widget crearPantalla() {
      return const MaterialApp(
        home: EstadisticasScreen(),
      );
    }

    testWidgets('Muestra título Estadísticas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(crearPantalla());
      await tester.pumpAndSettle();

      expect(find.text('Estadísticas'), findsOneWidget);
    });

    testWidgets('Muestra sección Ingresos vs Gastos',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(crearPantalla());
      await tester.pumpAndSettle();

      expect(find.text('Ingresos vs Gastos'), findsOneWidget);
      expect(find.text('Total ingresos'), findsOneWidget);
      expect(find.text('Total gastos'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
    });

    testWidgets('Muestra sección Gastos Hormiga',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(crearPantalla());
      await tester.pumpAndSettle();

      expect(find.text('Gastos Hormiga'), findsOneWidget);
      expect(find.text('Total hormiga'), findsOneWidget);
    });

    testWidgets('Muestra sección Distribución Banco / Efectivo',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(crearPantalla());
      await tester.pumpAndSettle();

      expect(
          find.text('Distribución Banco / Efectivo'), findsOneWidget);
      expect(find.text('Saldo Banco'), findsOneWidget);
      expect(find.text('Saldo Efectivo'), findsOneWidget);
    });

    testWidgets('Muestra sección Gastos por Categoría',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(crearPantalla());
      await tester.pumpAndSettle();

      // La sección puede estar fuera de la vista inicial, hacer scroll
      await tester.scrollUntilVisible(
        find.text('Gastos por Categoría'),
        200,
      );
      await tester.pumpAndSettle();

      expect(find.text('Gastos por Categoría'), findsOneWidget);
    });

    testWidgets('Muestra botón de actualizar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(crearPantalla());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });
  });
}
