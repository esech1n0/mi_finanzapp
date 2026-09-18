/// Tipos de movimiento financiero.
enum TipoMovimiento { ingreso, gasto }

/// Ubicación del dinero.
enum UbicacionMovimiento { banco, efectivo }

/// Modelo principal de la aplicación.
///
/// Los montos se almacenan como enteros en centavos para evitar
/// errores de precisión de punto flotante.
/// Ejemplo: $150.50 se almacena como 15050.
class Movimiento {
  final int? id;
  final TipoMovimiento tipo;
  final int montoCentavos;
  final String descripcion;
  final String categoria;
  final DateTime fecha;
  final UbicacionMovimiento ubicacion;
  final bool gastoHormiga;

  Movimiento({
    this.id,
    required this.tipo,
    required this.montoCentavos,
    required this.descripcion,
    required this.categoria,
    required this.fecha,
    required this.ubicacion,
    this.gastoHormiga = false,
  });

  /// Monto como double para mostrar en la UI.
  double get monto => montoCentavos / 100.0;

  /// Convierte pesos (double) a centavos (int).
  static int pesosToCentavos(double pesos) => (pesos * 100).round();

  /// Crea un [Movimiento] desde un mapa de la base de datos.
  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] as int?,
      tipo: map['tipo'] == 'ingreso'
          ? TipoMovimiento.ingreso
          : TipoMovimiento.gasto,
      montoCentavos: map['monto_centavos'] as int,
      descripcion: map['descripcion'] as String,
      categoria: map['categoria'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      ubicacion: map['ubicacion'] == 'banco'
          ? UbicacionMovimiento.banco
          : UbicacionMovimiento.efectivo,
      gastoHormiga: (map['gasto_hormiga'] as int) == 1,
    );
  }

  /// Convierte a mapa para insertar en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tipo': tipo == TipoMovimiento.ingreso ? 'ingreso' : 'gasto',
      'monto_centavos': montoCentavos,
      'descripcion': descripcion,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
      'ubicacion':
          ubicacion == UbicacionMovimiento.banco ? 'banco' : 'efectivo',
      'gasto_hormiga': gastoHormiga ? 1 : 0,
    };
  }

  /// Crea una copia con campos modificados.
  Movimiento copyWith({
    int? id,
    TipoMovimiento? tipo,
    int? montoCentavos,
    String? descripcion,
    String? categoria,
    DateTime? fecha,
    UbicacionMovimiento? ubicacion,
    bool? gastoHormiga,
  }) {
    return Movimiento(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      montoCentavos: montoCentavos ?? this.montoCentavos,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
      ubicacion: ubicacion ?? this.ubicacion,
      gastoHormiga: gastoHormiga ?? this.gastoHormiga,
    );
  }
}

/// Categorías predefinidas para ingresos.
const categoriasIngreso = [
  'Salario',
  'Freelance',
  'Venta',
  'Regalo',
  'Reembolso',
  'Inversión',
  'Otro',
];

/// Categorías predefinidas para gastos.
const categoriasGasto = [
  'Comida',
  'Transporte',
  'Entretenimiento',
  'Salud',
  'Educación',
  'Ropa',
  'Hogar',
  'Servicios',
  'Suscripciones',
  'Regalos',
  'Otro',
];
