import 'package:flutter_test/flutter_test.dart';
import 'package:mi_finanzapp/models/movimiento.dart';
import 'package:mi_finanzapp/database/database_helper.dart';

void main() {
  group('Modelo Movimiento', () {
    test('Conversión correcta entre pesos y centavos para evitar errores flotantes', () {
      expect(Movimiento.pesosToCentavos(100.00), equals(10000));
      expect(Movimiento.pesosToCentavos(150.50), equals(15050));
      expect(Movimiento.pesosToCentavos(0.99), equals(99));
      expect(Movimiento.pesosToCentavos(1234.56), equals(123456));

      final mov = Movimiento(
        tipo: TipoMovimiento.gasto,
        montoCentavos: 15050,
        descripcion: 'Café',
        categoria: 'Comida',
        fecha: DateTime(2026, 9, 17),
        ubicacion: UbicacionMovimiento.efectivo,
        gastoHormiga: true,
      );

      expect(mov.monto, equals(150.50));
      expect(mov.gastoHormiga, isTrue);
    });

    test('Serialización toMap y deserialización fromMap', () {
      final fecha = DateTime(2026, 9, 17, 10, 30);
      final original = Movimiento(
        id: 1,
        tipo: TipoMovimiento.ingreso,
        montoCentavos: 500000, // $5,000.00
        descripcion: 'Quincena',
        categoria: 'Salario',
        fecha: fecha,
        ubicacion: UbicacionMovimiento.banco,
        gastoHormiga: false,
      );

      final map = original.toMap();
      expect(map['id'], equals(1));
      expect(map['tipo'], equals('ingreso'));
      expect(map['monto_centavos'], equals(500000));
      expect(map['ubicacion'], equals('banco'));
      expect(map['gasto_hormiga'], equals(0));

      final recuperado = Movimiento.fromMap(map);
      expect(recuperado.id, equals(1));
      expect(recuperado.tipo, equals(TipoMovimiento.ingreso));
      expect(recuperado.montoCentavos, equals(500000));
      expect(recuperado.monto, equals(5000.0));
      expect(recuperado.descripcion, equals('Quincena'));
      expect(recuperado.categoria, equals('Salario'));
      expect(recuperado.fecha, equals(fecha));
      expect(recuperado.ubicacion, equals(UbicacionMovimiento.banco));
      expect(recuperado.gastoHormiga, isFalse);
    });

    test('Gasto hormiga se serializa correctamente a 1 y 0', () {
      final hormiga = Movimiento(
        tipo: TipoMovimiento.gasto,
        montoCentavos: 3500,
        descripcion: 'Refresco',
        categoria: 'Comida',
        fecha: DateTime.now(),
        ubicacion: UbicacionMovimiento.efectivo,
        gastoHormiga: true,
      );
      expect(hormiga.toMap()['gasto_hormiga'], equals(1));

      final noHormiga = hormiga.copyWith(gastoHormiga: false);
      expect(noHormiga.toMap()['gasto_hormiga'], equals(0));
    });
  });

  group('Reglas de cálculo de saldo y ResumenFinanciero', () {
    test('Saldo banco = ingresos banco - gastos banco, Saldo efectivo = ingresos efectivo - gastos efectivo, Saldo total = saldo banco + saldo efectivo', () {
      // Ingreso banco: $1000.00 (100000 centavos)
      // Gasto banco: $250.00 (25000 centavos)
      // Saldo banco esperado: $750.00 (75000 centavos)
      final saldoBancoCentavos = 100000 - 25000;

      // Ingreso efectivo: $500.00 (50000 centavos)
      // Gasto efectivo: $150.00 (15000 centavos)
      // Saldo efectivo esperado: $350.00 (35000 centavos)
      final saldoEfectivoCentavos = 50000 - 15000;

      final totalIngresosCentavos = 100000 + 50000;
      final totalGastosCentavos = 25000 + 15000;
      final totalHormigaCentavos = 5000; // $50.00 de gasto hormiga

      final resumen = ResumenFinanciero(
        totalIngresosCentavos: totalIngresosCentavos,
        totalGastosCentavos: totalGastosCentavos,
        totalHormigaCentavos: totalHormigaCentavos,
        saldoBancoCentavos: saldoBancoCentavos,
        saldoEfectivoCentavos: saldoEfectivoCentavos,
      );

      // Verificación de reglas estrictas
      expect(resumen.saldoBancoCentavos, equals(75000));
      expect(resumen.saldoBanco, equals(750.0));

      expect(resumen.saldoEfectivoCentavos, equals(35000));
      expect(resumen.saldoEfectivo, equals(350.0));

      expect(resumen.saldoTotalCentavos, equals(resumen.saldoBancoCentavos + resumen.saldoEfectivoCentavos));
      expect(resumen.saldoTotalCentavos, equals(110000));
      expect(resumen.saldoTotal, equals(1100.0));

      expect(resumen.totalIngresos, equals(1500.0));
      expect(resumen.totalGastos, equals(400.0));
      expect(resumen.totalHormiga, equals(50.0));
    });
  });
}
