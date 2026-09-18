import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/movimiento.dart';
import '../widgets/movimiento_tile.dart';

enum FiltroHistorial {
  todos,
  ingresos,
  gastos,
  hormiga,
  banco,
  efectivo,
}

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  FiltroHistorial _filtroActual = FiltroHistorial.todos;
  List<Movimiento> _movimientos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    cargarMovimientos();
  }

  Future<void> cargarMovimientos() async {
    setState(() => _cargando = true);

    TipoMovimiento? tipo;
    UbicacionMovimiento? ubicacion;
    bool? soloHormiga;

    switch (_filtroActual) {
      case FiltroHistorial.todos:
        break;
      case FiltroHistorial.ingresos:
        tipo = TipoMovimiento.ingreso;
        break;
      case FiltroHistorial.gastos:
        tipo = TipoMovimiento.gasto;
        break;
      case FiltroHistorial.hormiga:
        tipo = TipoMovimiento.gasto;
        soloHormiga = true;
        break;
      case FiltroHistorial.banco:
        ubicacion = UbicacionMovimiento.banco;
        break;
      case FiltroHistorial.efectivo:
        ubicacion = UbicacionMovimiento.efectivo;
        break;
    }

    try {
      final lista = await _dbHelper.obtenerMovimientos(
        tipo: tipo,
        ubicacion: ubicacion,
        soloHormiga: soloHormiga,
      );
      if (mounted) {
        setState(() {
          _movimientos = lista;
          _cargando = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _confirmarEliminacion(Movimiento mov) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1D172E),
        title: const Text(
          'Eliminar movimiento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${mov.descripcion}"?',
          style: const TextStyle(color: Color(0xFFB8B1CC)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFFB8B1CC))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mov.id != null) {
      await _dbHelper.eliminarMovimiento(mov.id!);
      await cargarMovimientos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimiento eliminado'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF2E2448),
          ),
        );
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
        title: const Text(
          'Historial',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFFF3EFFF),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFB8B1CC)),
            tooltip: 'Actualizar',
            onPressed: cargarMovimientos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra horizontal de filtros sencillos
          _buildBarraFiltros(),
          const SizedBox(height: 8),

          // Lista de movimientos
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF9D65FF)),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF9D65FF),
                    backgroundColor: const Color(0xFF1D172E),
                    onRefresh: cargarMovimientos,
                    child: _movimientos.isEmpty
                        ? _buildEstadoVacio()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 20),
                            itemCount: _movimientos.length,
                            itemBuilder: (context, index) {
                              final mov = _movimientos[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: MovimientoTile(
                                  movimiento: mov,
                                  onTap: () => _mostrarDetalles(mov),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          _buildChipFiltro(FiltroHistorial.todos, 'Todos'),
          const SizedBox(width: 8),
          _buildChipFiltro(FiltroHistorial.ingresos, 'Ingresos'),
          const SizedBox(width: 8),
          _buildChipFiltro(FiltroHistorial.gastos, 'Gastos'),
          const SizedBox(width: 8),
          _buildChipFiltro(FiltroHistorial.hormiga, 'Gastos hormiga 🐜'),
          const SizedBox(width: 8),
          _buildChipFiltro(FiltroHistorial.banco, 'Banco'),
          const SizedBox(width: 8),
          _buildChipFiltro(FiltroHistorial.efectivo, 'Efectivo'),
        ],
      ),
    );
  }

  Widget _buildChipFiltro(FiltroHistorial filtro, String etiqueta) {
    final seleccionado = _filtroActual == filtro;
    return ChoiceChip(
      label: Text(
        etiqueta,
        style: TextStyle(
          color: seleccionado ? Colors.white : const Color(0xFFB8B1CC),
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
      selected: seleccionado,
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _filtroActual = filtro);
          cargarMovimientos();
        }
      },
      selectedColor: const Color(0xFF7C4DFF),
      backgroundColor: const Color(0xFF1D172E),
      side: BorderSide(
        color: seleccionado ? const Color(0xFF9D65FF) : const Color(0xFF2E2448),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildEstadoVacio() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D172E),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2E2448)),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin movimientos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'No hay movimientos para el filtro seleccionado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB8B1CC),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarDetalles(Movimiento mov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D172E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mov.tipo == TipoMovimiento.ingreso ? 'Ingreso' : 'Gasto',
                  style: TextStyle(
                    color: mov.tipo == TipoMovimiento.ingreso
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Eliminar',
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmarEliminacion(mov);
                  },
                ),
              ],
            ),
            const Divider(color: Color(0xFF2E2448)),
            const SizedBox(height: 8),
            _buildDetalleFila('Descripción', mov.descripcion),
            _buildDetalleFila('Monto', '\$${mov.monto.toStringAsFixed(2)}'),
            _buildDetalleFila('Categoría', mov.categoria),
            _buildDetalleFila('Ubicación', mov.ubicacion == UbicacionMovimiento.banco ? 'Banco' : 'Efectivo'),
            _buildDetalleFila('Gasto hormiga', mov.gastoHormiga ? 'Sí 🐜' : 'No'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleFila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFB8B1CC), fontSize: 14)),
          Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
