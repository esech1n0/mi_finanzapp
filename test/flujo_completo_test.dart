import 'package:flutter_test/flutter_test.dart';
import 'package:mi_finanzapp/models/movimiento.dart';
import 'package:mi_finanzapp/database/database_helper.dart';

void main() {
  group('Flujo completo y reglas de negocio', () {
    test('Cálculo integral de saldos y resumen financiero', () {
      // 1. Ingreso en banco: $1,000.00
      final ingBanco = Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoCentavos: Movimiento.pesosToCentavos(1000.00),
        descripcion: 'Sueldo quincenal',
        categoria: 'Salario',
        fecha: DateTime(2026, 1, 15),
        ubicacion: UbicacionMovimiento.banco,
      );

      // 2. Ingreso en efectivo: $500.00
      final ingEfectivo = Movimiento(
        tipo: TipoMovimiento.ingreso,
        montoCentavos: Movimiento.pesosToCentavos(500.00),
        descripcion: 'Venta garage',
        categoria: 'Venta',
        fecha: DateTime(2026, 1, 16),
        ubicacion: UbicacionMovimiento.efectivo,
      );

      // 3. Gasto en banco (no hormiga): $250.00
      final gastoBanco = Movimiento(
        tipo: TipoMovimiento.gasto,
        montoCentavos: Movimiento.pesosToCentavos(250.00),
        descripcion: 'Supermercado',
        categoria: 'Comida',
        fecha: DateTime(2026, 1, 17),
        ubicacion: UbicacionMovimiento.banco,
        gastoHormiga: false,
      );

      // 4. Gasto en efectivo marcado manualmente como hormiga: $45.50
      final gastoHormigaEfectivo = Movimiento(
        tipo: TipoMovimiento.gasto,
        montoCentavos: Movimiento.pesosToCentavos(45.50),
        descripcion: 'Café y galleta',
        categoria: 'Comida',
        fecha: DateTime(2026, 1, 18),
        ubicacion: UbicacionMovimiento.efectivo,
        gastoHormiga: true,
      );

      // 5. Gasto en banco marcado manualmente como hormiga: $30.00
      final gastoHormigaBanco = Movimiento(
        tipo: TipoMovimiento.gasto,
        montoCentavos: Movimiento.pesosToCentavos(30.00),
        descripcion: 'App suscripción barata',
        categoria: 'Suscripciones',
        fecha: DateTime(2026, 1, 19),
        ubicacion: UbicacionMovimiento.banco,
        gastoHormiga: true,
      );

      final movimientos = [
        ingBanco,
        ingEfectivo,
        gastoBanco,
        gastoHormigaEfectivo,
        gastoHormigaBanco,
      ];

      // Sumar ingresos y gastos por ubicación
      int ingresosBanco = 0;
      int gastosBanco = 0;
      int ingresosEfectivo = 0;
      int gastosEfectivo = 0;
      int totalHormiga = 0;

      for (final m in movimientos) {
        if (m.tipo == TipoMovimiento.ingreso) {
          if (m.ubicacion == UbicacionMovimiento.banco) {
            ingresosBanco += m.montoCentavos;
          } else {
            ingresosEfectivo += m.montoCentavos;
          }
        } else {
          if (m.ubicacion == UbicacionMovimiento.banco) {
            gastosBanco += m.montoCentavos;
          } else {
            gastosEfectivo += m.montoCentavos;
          }
          if (m.gastoHormiga) {
            totalHormiga += m.montoCentavos;
          }
        }
      }

      final saldoBanco = ingresosBanco - gastosBanco;
      final saldoEfectivo = ingresosEfectivo - gastosEfectivo;
      final totalIngresos = ingresosBanco + ingresosEfectivo;
      final totalGastos = gastosBanco + gastosEfectivo;

      final resumen = ResumenFinanciero(
        totalIngresosCentavos: totalIngresos,
        totalGastosCentavos: totalGastos,
        totalHormigaCentavos: totalHormiga,
        saldoBancoCentavos: saldoBanco,
        saldoEfectivoCentavos: saldoEfectivo,
      );

      // Verificación de reglas financieras exactas:
      // Saldo banco = 1000.00 - (250.00 + 30.00) = 720.00
      expect(resumen.saldoBanco, 720.00);

      // Saldo efectivo = 500.00 - 45.50 = 454.50
      expect(resumen.saldoEfectivo, 454.50);

      // Saldo total = saldo banco + saldo efectivo = 720.00 + 454.50 = 1174.50
      expect(resumen.saldoTotal, 1174.50);

      // Total ingresos = 1000 + 500 = 1500.00
      expect(resumen.totalIngresos, 1500.00);

      // Total gastos = 250 + 45.50 + 30 = 325.50
      expect(resumen.totalGastos, 325.50);

      // Total gastos hormiga = 45.50 + 30 = 75.50
      expect(resumen.totalHormiga, 75.50);
    });

    test('Validación de serialización y consistencia de toMap / fromMap', () {
      final movOriginal = Movimiento(
        id: 42,
        tipo: TipoMovimiento.gasto,
        montoCentavos: 1299,
        descripcion: 'Tacos al pastor',
        categoria: 'Comida',
        fecha: DateTime(2026, 3, 10, 14, 30),
        ubicacion: UbicacionMovimiento.efectivo,
        gastoHormiga: true,
      );

      final map = movOriginal.toMap();
      final movRestaurado = Movimiento.fromMap(map);

      expect(movRestaurado.id, movOriginal.id);
      expect(movRestaurado.tipo, movOriginal.tipo);
      expect(movRestaurado.montoCentavos, movOriginal.montoCentavos);
      expect(movRestaurado.monto, 12.99);
      expect(movRestaurado.descripcion, movOriginal.descripcion);
      expect(movRestaurado.categoria, movOriginal.categoria);
      expect(movRestaurado.fecha, movOriginal.fecha);
      expect(movRestaurado.ubicacion, movOriginal.ubicacion);
      expect(movRestaurado.gastoHormiga, isTrue);
    });
  });
}
