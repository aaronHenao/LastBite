import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../domain/producto.dart';

part 'app_database.g.dart';

// ── Tabla de productos ────────────────────────────────────────────────────────

class ProductosTable extends Table {
  @override
  String get tableName => 'productos';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get nombre => text()();
  TextColumn get emoji => text()();
  TextColumn get categoria => text()();
  TextColumn get cantidad => text()();
  TextColumn get fechaCaducidad => text()(); // ISO8601
  BoolColumn get esFresco => boolean()();
  TextColumn get codigoBarras => text().nullable()();
  TextColumn get imagenUrl => text().nullable()();

  /// synced | pendingSync | failedSync
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id, userId};
}

// ── Base de datos ─────────────────────────────────────────────────────────────

@DriftDatabase(tables: [ProductosTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'lastbite_db');
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Inserta o actualiza un producto en la base local.
  Future<void> insertarOActualizar(String userId, Producto producto) async {
    await into(productosTable).insertOnConflictUpdate(
      ProductosTableCompanion(
        id: Value(producto.id),
        userId: Value(userId),
        nombre: Value(producto.nombre),
        emoji: Value(producto.emoji),
        categoria: Value(producto.categoria),
        cantidad: Value(producto.cantidad),
        fechaCaducidad: Value(producto.fechaCaducidad.toIso8601String()),
        esFresco: Value(producto.esFresco),
        codigoBarras: Value(producto.codigoBarras),
        imagenUrl: Value(producto.imagenUrl),
        syncStatus: Value(producto.syncStatus.name),
      ),
    );
  }

  /// Obtiene todos los productos de un usuario.
  Future<List<Producto>> obtenerProductos(String userId) async {
    final rows = await (select(productosTable)
          ..where((t) => t.userId.equals(userId)))
        .get();
    return rows.map(_rowToProducto).toList();
  }

  /// Obtiene solo los productos con syncStatus = pendingSync.
  Future<List<Producto>> obtenerPendientes(String userId) async {
    final rows = await (select(productosTable)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.syncStatus.equals(SyncStatus.pendingSync.name),
          ))
        .get();
    return rows.map(_rowToProducto).toList();
  }

  /// Elimina un producto por id.
  Future<void> eliminarProducto(String userId, String id) async {
    await (delete(productosTable)
          ..where((t) => t.id.equals(id) & t.userId.equals(userId)))
        .go();
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Producto _rowToProducto(ProductosTableData row) {
    return Producto(
      id: row.id,
      nombre: row.nombre,
      emoji: row.emoji,
      categoria: row.categoria,
      cantidad: row.cantidad,
      fechaCaducidad: DateTime.parse(row.fechaCaducidad),
      esFresco: row.esFresco,
      codigoBarras: row.codigoBarras,
      imagenUrl: row.imagenUrl,
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == row.syncStatus,
        orElse: () => SyncStatus.synced,
      ),
    );
  }
}
