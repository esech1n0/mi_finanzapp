import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/movimiento.dart';

/// Pantalla de formulario para registrar un Movimiento (Ingreso o Gasto).
class FormularioMovimientoScreen extends StatefulWidget {
  final TipoMovimiento tipo;

  const FormularioMovimientoScreen({
    super.key,
    required this.tipo,
  });

  @override
  State<FormularioMovimientoScreen> createState() =>
      _FormularioMovimientoScreenState();
}

class _FormularioMovimientoScreenState
    extends State<FormularioMovimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();

  late UbicacionMovimiento _ubicacion;
  late String _categoriaSeleccionada;
  late DateTime _fechaSeleccionada;
  bool _gastoHormiga = false;
  bool _guardando = false;

  bool get _esIngreso => widget.tipo == TipoMovimiento.ingreso;

  @override
  void initState() {
    super.initState();
    _ubicacion = UbicacionMovimiento.banco;
    _fechaSeleccionada = DateTime.now();

    final listaCategorias =
        _esIngreso ? categoriasIngreso : categoriasGasto;
    _categoriaSeleccionada = listaCategorias.first;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9D65FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1D172E),
              onSurface: Color(0xFFEAE6F5),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1D172E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _fechaSeleccionada = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _fechaSeleccionada.hour,
          _fechaSeleccionada.minute,
        );
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final montoLimpio =
        _montoController.text.trim().replaceAll(',', '.');
    final montoDouble = double.tryParse(montoLimpio);

    if (montoDouble == null || montoDouble <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un monto válido mayor que cero.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final montoCentavos = Movimiento.pesosToCentavos(montoDouble);
      final nuevoMovimiento = Movimiento(
        tipo: widget.tipo,
        montoCentavos: montoCentavos,
        descripcion: _descripcionController.text.trim(),
        categoria: _categoriaSeleccionada,
        fecha: _fechaSeleccionada,
        ubicacion: _ubicacion,
        gastoHormiga: _esIngreso ? false : _gastoHormiga,
      );

      await DatabaseHelper().insertarMovimiento(nuevoMovimiento);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esIngreso ? 'Ingreso registrado correctamente' : 'Gasto registrado correctamente',
            ),
            backgroundColor: _esIngreso ? const Color(0xFF2E7D32) : const Color(0xFF9D65FF),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el movimiento. Intenta de nuevo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorAcento =
        _esIngreso ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final categorias =
        _esIngreso ? categoriasIngreso : categoriasGasto;

    return Scaffold(
      backgroundColor: const Color(0xFF120E1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF120E1C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          _esIngreso ? 'Agregar Ingreso' : 'Agregar Gasto',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de Monto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D172E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2448)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monto (\$)',
                        style: TextStyle(
                          color: Color(0xFFB8B1CC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _montoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          color: colorAcento,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: Colors.white.withAlpha(50),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(
                            color: colorAcento,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa un monto';
                          }
                          final d = double.tryParse(val.trim().replaceAll(',', '.'));
                          if (d == null) {
                            return 'Monto inválido';
                          }
                          if (d <= 0) {
                            return 'El monto debe ser mayor que cero';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Descripción
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D172E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2448)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          color: Color(0xFFB8B1CC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descripcionController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: _esIngreso ? 'Ej. Depósito quincena, Venta' : 'Ej. Comida corrida, Café',
                          hintStyle: TextStyle(color: Colors.white.withAlpha(70)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de Ubicación del dinero (Banco / Efectivo)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D172E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2448)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿Dónde ocurrió el movimiento?',
                        style: TextStyle(
                          color: Color(0xFFB8B1CC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOpcionUbicacion(
                              titulo: 'Banco',
                              icono: Icons.account_balance_rounded,
                              seleccionada: _ubicacion == UbicacionMovimiento.banco,
                              onTap: () {
                                setState(() => _ubicacion = UbicacionMovimiento.banco);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildOpcionUbicacion(
                              titulo: 'Efectivo',
                              icono: Icons.payments_rounded,
                              seleccionada: _ubicacion == UbicacionMovimiento.efectivo,
                              onTap: () {
                                setState(() => _ubicacion = UbicacionMovimiento.efectivo);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de Categoría
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D172E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2448)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categoría',
                        style: TextStyle(
                          color: Color(0xFFB8B1CC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _categoriaSeleccionada,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF231A38),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB8B1CC)),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          items: categorias.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (nueva) {
                            if (nueva != null) {
                              setState(() => _categoriaSeleccionada = nueva);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de Fecha
                InkWell(
                  onTap: _seleccionarFecha,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D172E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2E2448)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fecha',
                              style: TextStyle(
                                color: Color(0xFFB8B1CC),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2448),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF9D65FF),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Campo condicional para Gasto Hormiga (solo para gastos)
                if (!_esIngreso) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D172E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2E2448)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('🐜', style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '¿Es gasto hormiga?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Compra pequeña cotidiana (café, snack, etc.)',
                                style: TextStyle(
                                  color: Color(0xFFB8B1CC),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _gastoHormiga,
                          activeThumbColor: const Color(0xFF9D65FF),
                          onChanged: (val) {
                            setState(() => _gastoHormiga = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Botón Guardar
                ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAcento,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _guardando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _esIngreso ? 'Guardar Ingreso' : 'Guardar Gasto',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpcionUbicacion({
    required String titulo,
    required IconData icono,
    required bool seleccionada,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: seleccionada ? const Color(0xFF38235E) : const Color(0xFF140F21),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionada ? const Color(0xFF9D65FF) : const Color(0xFF2E2448),
            width: seleccionada ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 18,
              color: seleccionada ? Colors.white : const Color(0xFFB8B1CC),
            ),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                color: seleccionada ? Colors.white : const Color(0xFFB8B1CC),
                fontWeight: seleccionada ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
