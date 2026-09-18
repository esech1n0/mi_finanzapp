import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

/// Pantalla de estadísticas financieras.
///
/// Muestra:
/// - Total ingresos vs Total gastos (con barra comparativa)
/// - Total gastos hormiga (proporción sobre gastos totales)
/// - Distribución saldo banco / saldo efectivo
/// - Gastos por categoría con barras de progreso
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _cargando = true;

  ResumenFinanciero? _resumen;
  Map<String, int> _gastosPorCategoria = {};

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _cargando = true);
    try {
      final resumen = await _dbHelper.obtenerResumen();
      final categorias = await _dbHelper.gastosPorCategoria();

      if (mounted) {
        setState(() {
          _resumen = resumen;
          _gastosPorCategoria = categorias;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120E1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF120E1C),
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, color: Color(0xFF9D65FF)),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Estadísticas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFFF3EFFF),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFB8B1CC)),
            tooltip: 'Actualizar',
            onPressed: _cargarEstadisticas,
          ),
        ],
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9D65FF)),
            )
          : RefreshIndicator(
              color: const Color(0xFF9D65FF),
              backgroundColor: const Color(0xFF1D172E),
              onRefresh: _cargarEstadisticas,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildSeccionIngresosGastos(),
                  const SizedBox(height: 14),
                  _buildSeccionHormiga(),
                  const SizedBox(height: 14),
                  _buildSeccionDistribucion(),
                  const SizedBox(height: 14),
                  _buildSeccionCategorias(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // --- Secciones ---

  /// Sección de Ingresos vs Gastos con barra comparativa.
  Widget _buildSeccionIngresosGastos() {
    final ingresos = _resumen?.totalIngresos ?? 0.0;
    final gastos = _resumen?.totalGastos ?? 0.0;
    final mayor =
        ingresos > gastos ? ingresos : (gastos > 0 ? gastos : 1.0);

    return _buildTarjeta(
      titulo: 'Ingresos vs Gastos',
      icono: Icons.compare_arrows_rounded,
      child: Column(
        children: [
          _buildFilaEstadistica(
            etiqueta: 'Total ingresos',
            monto: ingresos,
            color: Colors.greenAccent,
            proporcion: mayor > 0 ? ingresos / mayor : 0,
          ),
          const SizedBox(height: 14),
          _buildFilaEstadistica(
            etiqueta: 'Total gastos',
            monto: gastos,
            color: Colors.redAccent,
            proporcion: mayor > 0 ? gastos / mayor : 0,
          ),
          const SizedBox(height: 14),
          // Balance
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF120E1C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    color: Color(0xFFD6CEEB),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _currencyFormat.format(ingresos - gastos),
                    style: TextStyle(
                      color: (ingresos - gastos) >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de gastos hormiga.
  Widget _buildSeccionHormiga() {
    final hormiga = _resumen?.totalHormiga ?? 0.0;
    final gastos = _resumen?.totalGastos ?? 0.0;
    final porcentajeHormiga = gastos > 0 ? (hormiga / gastos) : 0.0;

    return _buildTarjeta(
      titulo: 'Gastos Hormiga',
      icono: Icons.bug_report_rounded,
      iconoColor: const Color(0xFFFFB74D),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total hormiga',
                style: TextStyle(
                  color: Color(0xFFD6CEEB),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _currencyFormat.format(hormiga),
                  style: const TextStyle(
                    color: Color(0xFFFFB74D),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: porcentajeHormiga.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFF2E2448),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            gastos > 0
                ? '${(porcentajeHormiga * 100).toStringAsFixed(1)}% de tus gastos son hormiga'
                : 'Sin gastos registrados',
            style: const TextStyle(
              color: Color(0xFFB8B1CC),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de distribución Banco / Efectivo.
  Widget _buildSeccionDistribucion() {
    final saldoBanco = _resumen?.saldoBanco ?? 0.0;
    final saldoEfectivo = _resumen?.saldoEfectivo ?? 0.0;
    final totalAbs = saldoBanco.abs() + saldoEfectivo.abs();
    final propBanco = totalAbs > 0 ? saldoBanco.abs() / totalAbs : 0.5;

    return _buildTarjeta(
      titulo: 'Distribución Banco / Efectivo',
      icono: Icons.account_balance_wallet_rounded,
      child: Column(
        children: [
          _buildFilaDistribucion(
            etiqueta: 'Saldo Banco',
            monto: saldoBanco,
            icono: Icons.account_balance_rounded,
            color: const Color(0xFF64B5F6),
          ),
          const SizedBox(height: 12),
          _buildFilaDistribucion(
            etiqueta: 'Saldo Efectivo',
            monto: saldoEfectivo,
            icono: Icons.payments_rounded,
            color: const Color(0xFF81C784),
          ),
          const SizedBox(height: 14),
          // Barra apilada Banco vs Efectivo
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: (propBanco * 100).round().clamp(1, 99),
                    child: Container(color: const Color(0xFF64B5F6)),
                  ),
                  Flexible(
                    flex: ((1 - propBanco) * 100).round().clamp(1, 99),
                    child: Container(color: const Color(0xFF81C784)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLeyenda(
                color: const Color(0xFF64B5F6),
                texto:
                    'Banco ${totalAbs > 0 ? '${(propBanco * 100).toStringAsFixed(0)}%' : '—'}',
              ),
              _buildLeyenda(
                color: const Color(0xFF81C784),
                texto:
                    'Efectivo ${totalAbs > 0 ? '${((1 - propBanco) * 100).toStringAsFixed(0)}%' : '—'}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sección de gastos por categoría.
  Widget _buildSeccionCategorias() {
    if (_gastosPorCategoria.isEmpty) {
      return _buildTarjeta(
        titulo: 'Gastos por Categoría',
        icono: Icons.category_rounded,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: Color(0xFF4C337C),
                  size: 36,
                ),
                SizedBox(height: 8),
                Text(
                  'No hay gastos registrados',
                  style: TextStyle(
                    color: Color(0xFFB8B1CC),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalCentavos =
        _gastosPorCategoria.values.fold<int>(0, (a, b) => a + b);

    const coloresCategoria = [
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF42A5F5),
      Color(0xFF26A69A),
      Color(0xFFFFA726),
      Color(0xFF66BB6A),
      Color(0xFFEC407A),
      Color(0xFF5C6BC0),
      Color(0xFF29B6F6),
      Color(0xFFFF7043),
      Color(0xFF9CCC65),
    ];

    final entradas = _gastosPorCategoria.entries.toList();

    return _buildTarjeta(
      titulo: 'Gastos por Categoría',
      icono: Icons.category_rounded,
      child: Column(
        children: [
          for (int i = 0; i < entradas.length; i++) ...[
            _buildFilaCategoria(
              categoria: entradas[i].key,
              monto: entradas[i].value / 100.0,
              proporcion: totalCentavos > 0
                  ? entradas[i].value / totalCentavos
                  : 0.0,
              color: coloresCategoria[i % coloresCategoria.length],
            ),
            if (i < entradas.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  // --- Widgets auxiliares ---

  /// Tarjeta contenedora reutilizable.
  Widget _buildTarjeta({
    required String titulo,
    required IconData icono,
    required Widget child,
    Color iconoColor = const Color(0xFF9D65FF),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1D172E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2448), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconoColor.withAlpha(35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: iconoColor, size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Fila con etiqueta, monto y barra de progreso.
  Widget _buildFilaEstadistica({
    required String etiqueta,
    required double monto,
    required Color color,
    required double proporcion,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                etiqueta,
                style: const TextStyle(
                  color: Color(0xFFD6CEEB),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _currencyFormat.format(monto),
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: proporcion.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFF2E2448),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Fila de distribución banco/efectivo.
  Widget _buildFilaDistribucion({
    required String etiqueta,
    required double monto,
    required IconData icono,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withAlpha(35),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: Color(0xFFD6CEEB),
              fontSize: 14,
            ),
          ),
        ),
        Flexible(
          child: Text(
            _currencyFormat.format(monto),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Leyenda pequeña con cuadrito de color y texto.
  Widget _buildLeyenda({required Color color, required String texto}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            color: Color(0xFFB8B1CC),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Fila individual de gasto por categoría.
  Widget _buildFilaCategoria({
    required String categoria,
    required double monto,
    required double proporcion,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                categoria,
                style: const TextStyle(
                  color: Color(0xFFD6CEEB),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(proporcion * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: color.withAlpha(200),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _currencyFormat.format(monto),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: proporcion.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: const Color(0xFF2E2448),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
