import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movimiento.dart';

/// Helper para manejar la base de datos SQLite local.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mifinanzapp.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movimientos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        monto_centavos INTEGER NOT NULL,
        descripcion TEXT NOT NULL,
        categoria TEXT NOT NULL,
        fecha TEXT NOT NULL,
        ubicacion TEXT NOT NULL,
        gasto_hormiga INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Inserta un movimiento y retorna su id generado.
  Future<int> insertarMovimiento(Movimiento movimiento) async {
    final db = await database;
    return await db.insert('movimientos', movimiento.toMap());
  }

  /// Obtiene movimientos ordenados por fecha descendente con filtros opcionales.
  Future<List<Movimiento>> obtenerMovimientos({
    TipoMovimiento? tipo,
    UbicacionMovimiento? ubicacion,
    bool? soloHormiga,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (tipo != null) {
      where.add('tipo = ?');
      args.add(tipo == TipoMovimiento.ingreso ? 'ingreso' : 'gasto');
    }
    if (ubicacion != null) {
      where.add('ubicacion = ?');
      args.add(ubicacion == UbicacionMovimiento.banco ? 'banco' : 'efectivo');
    }
    if (soloHormiga == true) {
      where.add('gasto_hormiga = 1');
    }

    final whereClause = where.isEmpty ? null : where.join(' AND ');
    final maps = await db.query(
      'movimientos',
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'fecha DESC, id DESC',
    );
    return maps.map((map) => Movimiento.fromMap(map)).toList();
  }

  /// Obtiene los últimos [limite] movimientos para el dashboard.
  Future<List<Movimiento>> obtenerMovimientosRecientes({int limite = 5}) async {
    final db = await database;
    final maps = await db.query(
      'movimientos',
      orderBy: 'fecha DESC, id DESC',
      limit: limite,
    );
    return maps.map((map) => Movimiento.fromMap(map)).toList();
  }

  /// Actualiza un movimiento existente.
  Future<int> actualizarMovimiento(Movimiento movimiento) async {
    final db = await database;
    return await db.update(
      'movimientos',
      movimiento.toMap(),
      where: 'id = ?',
      whereArgs: [movimiento.id],
    );
  }

  /// Elimina un movimiento por su id.
  Future<int> eliminarMovimiento(int id) async {
    final db = await database;
    return await db.delete(
      'movimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Consultas de resumen financiero ---

  /// Suma de centavos por tipo, ubicación o condición de hormiga.
  Future<int> _sumarCentavos({
    TipoMovimiento? tipo,
    UbicacionMovimiento? ubicacion,
    bool? soloHormiga,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (tipo != null) {
      where.add('tipo = ?');
      args.add(tipo == TipoMovimiento.ingreso ? 'ingreso' : 'gasto');
    }
    if (ubicacion != null) {
      where.add('ubicacion = ?');
      args.add(ubicacion == UbicacionMovimiento.banco ? 'banco' : 'efectivo');
    }
    if (soloHormiga == true) {
      where.add('gasto_hormiga = 1');
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(monto_centavos), 0) as total FROM movimientos $whereClause',
      args,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Retorna un resumen financiero completo con cálculo exacto de saldos:
  /// - Saldo banco = ingresos banco - gastos banco
  /// - Saldo efectivo = ingresos efectivo - gastos efectivo
  /// - Saldo total = saldo banco + saldo efectivo
  Future<ResumenFinanciero> obtenerResumen() async {
    final totalIngresos = await _sumarCentavos(tipo: TipoMovimiento.ingreso);
    final totalGastos = await _sumarCentavos(tipo: TipoMovimiento.gasto);
    final totalHormiga = await _sumarCentavos(
      tipo: TipoMovimiento.gasto,
      soloHormiga: true,
    );

    final ingresosBanco = await _sumarCentavos(
      tipo: TipoMovimiento.ingreso,
      ubicacion: UbicacionMovimiento.banco,
    );
    final gastosBanco = await _sumarCentavos(
      tipo: TipoMovimiento.gasto,
      ubicacion: UbicacionMovimiento.banco,
    );
    final ingresosEfectivo = await _sumarCentavos(
      tipo: TipoMovimiento.ingreso,
      ubicacion: UbicacionMovimiento.efectivo,
    );
    final gastosEfectivo = await _sumarCentavos(
      tipo: TipoMovimiento.gasto,
      ubicacion: UbicacionMovimiento.efectivo,
    );

    return ResumenFinanciero(
      totalIngresosCentavos: totalIngresos,
      totalGastosCentavos: totalGastos,
      totalHormigaCentavos: totalHormiga,
      saldoBancoCentavos: ingresosBanco - gastosBanco,
      saldoEfectivoCentavos: ingresosEfectivo - gastosEfectivo,
    );
  }

  /// Obtiene gastos agrupados por categoría.
  Future<Map<String, int>> gastosPorCategoria() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT categoria, SUM(monto_centavos) as total FROM movimientos WHERE tipo = 'gasto' GROUP BY categoria ORDER BY total DESC",
    );

    final map = <String, int>{};
    for (final row in result) {
      map[row['categoria'] as String] = row['total'] as int;
    }
    return map;
  }
}

/// Resumen financiero inmutable encapsulando las reglas de negocio.
class ResumenFinanciero {
  final int totalIngresosCentavos;
  final int totalGastosCentavos;
  final int totalHormigaCentavos;
  final int saldoBancoCentavos;
  final int saldoEfectivoCentavos;

  const ResumenFinanciero({
    required this.totalIngresosCentavos,
    required this.totalGastosCentavos,
    required this.totalHormigaCentavos,
    required this.saldoBancoCentavos,
    required this.saldoEfectivoCentavos,
  });

  /// Saldo total = saldo banco + saldo efectivo
  int get saldoTotalCentavos => saldoBancoCentavos + saldoEfectivoCentavos;

  double get saldoTotal => saldoTotalCentavos / 100.0;
  double get saldoBanco => saldoBancoCentavos / 100.0;
  double get saldoEfectivo => saldoEfectivoCentavos / 100.0;
  double get totalIngresos => totalIngresosCentavos / 100.0;
  double get totalGastos => totalGastosCentavos / 100.0;
  double get totalHormiga => totalHormigaCentavos / 100.0;
}
