import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/movimiento.dart';
import '../widgets/movimiento_tile.dart';
import 'formulario_movimiento_screen.dart';
import 'historial_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onAgregarIngreso;
  final VoidCallback? onAgregarGasto;

  const HomeScreen({
    super.key,
    this.onAgregarIngreso,
    this.onAgregarGasto,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _cargando = true;
  ResumenFinanciero? _resumen;
  List<Movimiento> _recientes = [];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final resumen = await _dbHelper.obtenerResumen();
      final recientes = await _dbHelper.obtenerMovimientosRecientes(limite: 5);
      if (mounted) {
        setState(() {
          _resumen = resumen;
          _recientes = recientes;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _abrirFormularioIngreso() async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioMovimientoScreen(
          tipo: TipoMovimiento.ingreso,
        ),
      ),
    );
    if (guardado == true) {
      await cargarDatos();
    }
  }

  Future<void> _abrirFormularioGasto() async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioMovimientoScreen(
          tipo: TipoMovimiento.gasto,
        ),
      ),
    );
    if (guardado == true) {
      await cargarDatos();
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
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF9D65FF)),
            SizedBox(width: 10),
            Text(
              'MiFinanzapp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFFF3EFFF),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFB8B1CC)),
            tooltip: 'Actualizar',
            onPressed: cargarDatos,
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
              onRefresh: cargarDatos,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Tarjeta Principal de Saldo Total
                  _buildTarjetaSaldoTotal(),
                  const SizedBox(height: 14),

                  // Desglose de Banco vs Efectivo
                  _buildFilaBancoEfectivo(),
                  const SizedBox(height: 14),

                  // Resumen: Ingresos, Gastos y Gastos Hormiga
                  _buildFilaResumen(),
                  const SizedBox(height: 18),

                  // Botones de acción principales
                  _buildBotonesAccion(),
                  const SizedBox(height: 20),

                  // Ubicación reservada para recurso visual futuro
                  _buildEspacioRecursoVisual(),
                  const SizedBox(height: 24),

                  // Sección de Movimientos Recientes
                  _buildSeccionMovimientosRecientes(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  /// Tarjeta con el saldo total destacado
  Widget _buildTarjetaSaldoTotal() {
    final saldo = _resumen?.saldoTotal ?? 0.0;
    final esPositivo = saldo >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF38235E), Color(0xFF23163D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4C337C), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Total Disponible',
                style: TextStyle(
                  color: Color(0xFFD6CEEB),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (esPositivo ? Colors.greenAccent : Colors.redAccent)
                      .withAlpha(35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  esPositivo ? 'Al corriente' : 'En negativo',
                  style: TextStyle(
                    color: esPositivo ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currencyFormat.format(saldo),
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(80),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjetas lado a lado para Banco y Efectivo
  Widget _buildFilaBancoEfectivo() {
    final saldoBanco = _resumen?.saldoBanco ?? 0.0;
    final saldoEfectivo = _resumen?.saldoEfectivo ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildTarjetaCuenta(
            titulo: 'Banco',
            monto: saldoBanco,
            icono: Icons.account_balance_rounded,
            colorIcono: const Color(0xFF64B5F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTarjetaCuenta(
            titulo: 'Efectivo',
            monto: saldoEfectivo,
            icono: Icons.payments_rounded,
            colorIcono: const Color(0xFF81C784),
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaCuenta({
    required String titulo,
    required double monto,
    required IconData icono,
    required Color colorIcono,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: colorIcono.withAlpha(35),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icono, color: colorIcono, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  color: Color(0xFFB8B1CC),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _currencyFormat.format(monto),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjetas de resumen: Ingresos, Gastos y Gastos Hormiga
  Widget _buildFilaResumen() {
    final ingresos = _resumen?.totalIngresos ?? 0.0;
    final gastos = _resumen?.totalGastos ?? 0.0;
    final hormiga = _resumen?.totalHormiga ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildItemResumen(
            titulo: 'Ingresos',
            monto: ingresos,
            color: Colors.greenAccent,
            icono: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildItemResumen(
            titulo: 'Gastos',
            monto: gastos,
            color: Colors.redAccent,
            icono: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildItemResumen(
            titulo: 'G. Hormiga',
            monto: hormiga,
            color: const Color(0xFFFFB74D),
            icono: Icons.bug_report_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildItemResumen({
    required String titulo,
    required double monto,
    required Color color,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D172E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E2448), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFFB8B1CC),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(monto),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Botones de acción principales: Agregar ingreso y Agregar gasto
  Widget _buildBotonesAccion() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onAgregarIngreso ?? _abrirFormularioIngreso,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: const Text(
              'Agregar ingreso',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onAgregarGasto ?? _abrirFormularioGasto,
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
            label: const Text(
              'Agregar gasto',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// Espacio reservado para el recurso visual futuro
  Widget _buildEspacioRecursoVisual() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1D172E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E2448), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2040),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9D65FF).withAlpha(80),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: Color(0xFF9D65FF),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finanzas Claras',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lleva el control de tus entradas, salidas y gastos hormiga.',
                  style: TextStyle(
                    color: Color(0xFFB8B1CC),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de movimientos recientes
  Widget _buildSeccionMovimientosRecientes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Movimientos recientes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistorialScreen(),
                    ),
                  ).then((_) => cargarDatos());
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: Color(0xFF9D65FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_recientes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1D172E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E2448), width: 1),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF4C337C),
                  size: 42,
                ),
                SizedBox(height: 10),
                Text(
                  'No hay movimientos registrados',
                  style: TextStyle(
                    color: Color(0xFFEAE6F5),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Usa los botones superiores para registrar tu primer ingreso o gasto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB8B1CC),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ..._recientes.map((mov) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: MovimientoTile(movimiento: mov),
              )),
      ],
    );
  }
}
