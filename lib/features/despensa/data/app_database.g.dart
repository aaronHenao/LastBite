// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductosTableTable extends ProductosTable
    with TableInfo<$ProductosTableTable, ProductosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<String> cantidad = GeneratedColumn<String>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCaducidadMeta = const VerificationMeta(
    'fechaCaducidad',
  );
  @override
  late final GeneratedColumn<String> fechaCaducidad = GeneratedColumn<String>(
    'fecha_caducidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _esFrescoMeta = const VerificationMeta(
    'esFresco',
  );
  @override
  late final GeneratedColumn<bool> esFresco = GeneratedColumn<bool>(
    'es_fresco',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_fresco" IN (0, 1))',
    ),
  );
  static const VerificationMeta _codigoBarrasMeta = const VerificationMeta(
    'codigoBarras',
  );
  @override
  late final GeneratedColumn<String> codigoBarras = GeneratedColumn<String>(
    'codigo_barras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagenUrlMeta = const VerificationMeta(
    'imagenUrl',
  );
  @override
  late final GeneratedColumn<String> imagenUrl = GeneratedColumn<String>(
    'imagen_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('synced'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    nombre,
    emoji,
    categoria,
    cantidad,
    fechaCaducidad,
    esFresco,
    codigoBarras,
    imagenUrl,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('fecha_caducidad')) {
      context.handle(
        _fechaCaducidadMeta,
        fechaCaducidad.isAcceptableOrUnknown(
          data['fecha_caducidad']!,
          _fechaCaducidadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaCaducidadMeta);
    }
    if (data.containsKey('es_fresco')) {
      context.handle(
        _esFrescoMeta,
        esFresco.isAcceptableOrUnknown(data['es_fresco']!, _esFrescoMeta),
      );
    } else if (isInserting) {
      context.missing(_esFrescoMeta);
    }
    if (data.containsKey('codigo_barras')) {
      context.handle(
        _codigoBarrasMeta,
        codigoBarras.isAcceptableOrUnknown(
          data['codigo_barras']!,
          _codigoBarrasMeta,
        ),
      );
    }
    if (data.containsKey('imagen_url')) {
      context.handle(
        _imagenUrlMeta,
        imagenUrl.isAcceptableOrUnknown(data['imagen_url']!, _imagenUrlMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  ProductosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cantidad'],
      )!,
      fechaCaducidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_caducidad'],
      )!,
      esFresco: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_fresco'],
      )!,
      codigoBarras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_barras'],
      ),
      imagenUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imagen_url'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ProductosTableTable createAlias(String alias) {
    return $ProductosTableTable(attachedDatabase, alias);
  }
}

class ProductosTableData extends DataClass
    implements Insertable<ProductosTableData> {
  final String id;
  final String userId;
  final String nombre;
  final String emoji;
  final String categoria;
  final String cantidad;
  final String fechaCaducidad;
  final bool esFresco;
  final String? codigoBarras;
  final String? imagenUrl;

  /// synced | pendingSync | failedSync
  final String syncStatus;
  const ProductosTableData({
    required this.id,
    required this.userId,
    required this.nombre,
    required this.emoji,
    required this.categoria,
    required this.cantidad,
    required this.fechaCaducidad,
    required this.esFresco,
    this.codigoBarras,
    this.imagenUrl,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['nombre'] = Variable<String>(nombre);
    map['emoji'] = Variable<String>(emoji);
    map['categoria'] = Variable<String>(categoria);
    map['cantidad'] = Variable<String>(cantidad);
    map['fecha_caducidad'] = Variable<String>(fechaCaducidad);
    map['es_fresco'] = Variable<bool>(esFresco);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    if (!nullToAbsent || imagenUrl != null) {
      map['imagen_url'] = Variable<String>(imagenUrl);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProductosTableCompanion toCompanion(bool nullToAbsent) {
    return ProductosTableCompanion(
      id: Value(id),
      userId: Value(userId),
      nombre: Value(nombre),
      emoji: Value(emoji),
      categoria: Value(categoria),
      cantidad: Value(cantidad),
      fechaCaducidad: Value(fechaCaducidad),
      esFresco: Value(esFresco),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      imagenUrl: imagenUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imagenUrl),
      syncStatus: Value(syncStatus),
    );
  }

  factory ProductosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductosTableData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      emoji: serializer.fromJson<String>(json['emoji']),
      categoria: serializer.fromJson<String>(json['categoria']),
      cantidad: serializer.fromJson<String>(json['cantidad']),
      fechaCaducidad: serializer.fromJson<String>(json['fechaCaducidad']),
      esFresco: serializer.fromJson<bool>(json['esFresco']),
      codigoBarras: serializer.fromJson<String?>(json['codigoBarras']),
      imagenUrl: serializer.fromJson<String?>(json['imagenUrl']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'nombre': serializer.toJson<String>(nombre),
      'emoji': serializer.toJson<String>(emoji),
      'categoria': serializer.toJson<String>(categoria),
      'cantidad': serializer.toJson<String>(cantidad),
      'fechaCaducidad': serializer.toJson<String>(fechaCaducidad),
      'esFresco': serializer.toJson<bool>(esFresco),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'imagenUrl': serializer.toJson<String?>(imagenUrl),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ProductosTableData copyWith({
    String? id,
    String? userId,
    String? nombre,
    String? emoji,
    String? categoria,
    String? cantidad,
    String? fechaCaducidad,
    bool? esFresco,
    Value<String?> codigoBarras = const Value.absent(),
    Value<String?> imagenUrl = const Value.absent(),
    String? syncStatus,
  }) => ProductosTableData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    nombre: nombre ?? this.nombre,
    emoji: emoji ?? this.emoji,
    categoria: categoria ?? this.categoria,
    cantidad: cantidad ?? this.cantidad,
    fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
    esFresco: esFresco ?? this.esFresco,
    codigoBarras: codigoBarras.present ? codigoBarras.value : this.codigoBarras,
    imagenUrl: imagenUrl.present ? imagenUrl.value : this.imagenUrl,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ProductosTableData copyWithCompanion(ProductosTableCompanion data) {
    return ProductosTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      fechaCaducidad: data.fechaCaducidad.present
          ? data.fechaCaducidad.value
          : this.fechaCaducidad,
      esFresco: data.esFresco.present ? data.esFresco.value : this.esFresco,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      imagenUrl: data.imagenUrl.present ? data.imagenUrl.value : this.imagenUrl,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductosTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nombre: $nombre, ')
          ..write('emoji: $emoji, ')
          ..write('categoria: $categoria, ')
          ..write('cantidad: $cantidad, ')
          ..write('fechaCaducidad: $fechaCaducidad, ')
          ..write('esFresco: $esFresco, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('imagenUrl: $imagenUrl, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    nombre,
    emoji,
    categoria,
    cantidad,
    fechaCaducidad,
    esFresco,
    codigoBarras,
    imagenUrl,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductosTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.nombre == this.nombre &&
          other.emoji == this.emoji &&
          other.categoria == this.categoria &&
          other.cantidad == this.cantidad &&
          other.fechaCaducidad == this.fechaCaducidad &&
          other.esFresco == this.esFresco &&
          other.codigoBarras == this.codigoBarras &&
          other.imagenUrl == this.imagenUrl &&
          other.syncStatus == this.syncStatus);
}

class ProductosTableCompanion extends UpdateCompanion<ProductosTableData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> nombre;
  final Value<String> emoji;
  final Value<String> categoria;
  final Value<String> cantidad;
  final Value<String> fechaCaducidad;
  final Value<bool> esFresco;
  final Value<String?> codigoBarras;
  final Value<String?> imagenUrl;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProductosTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.emoji = const Value.absent(),
    this.categoria = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.fechaCaducidad = const Value.absent(),
    this.esFresco = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.imagenUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosTableCompanion.insert({
    required String id,
    required String userId,
    required String nombre,
    required String emoji,
    required String categoria,
    required String cantidad,
    required String fechaCaducidad,
    required bool esFresco,
    this.codigoBarras = const Value.absent(),
    this.imagenUrl = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       nombre = Value(nombre),
       emoji = Value(emoji),
       categoria = Value(categoria),
       cantidad = Value(cantidad),
       fechaCaducidad = Value(fechaCaducidad),
       esFresco = Value(esFresco);
  static Insertable<ProductosTableData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? nombre,
    Expression<String>? emoji,
    Expression<String>? categoria,
    Expression<String>? cantidad,
    Expression<String>? fechaCaducidad,
    Expression<bool>? esFresco,
    Expression<String>? codigoBarras,
    Expression<String>? imagenUrl,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (nombre != null) 'nombre': nombre,
      if (emoji != null) 'emoji': emoji,
      if (categoria != null) 'categoria': categoria,
      if (cantidad != null) 'cantidad': cantidad,
      if (fechaCaducidad != null) 'fecha_caducidad': fechaCaducidad,
      if (esFresco != null) 'es_fresco': esFresco,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (imagenUrl != null) 'imagen_url': imagenUrl,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosTableCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? nombre,
    Value<String>? emoji,
    Value<String>? categoria,
    Value<String>? cantidad,
    Value<String>? fechaCaducidad,
    Value<bool>? esFresco,
    Value<String?>? codigoBarras,
    Value<String?>? imagenUrl,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ProductosTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nombre: nombre ?? this.nombre,
      emoji: emoji ?? this.emoji,
      categoria: categoria ?? this.categoria,
      cantidad: cantidad ?? this.cantidad,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      esFresco: esFresco ?? this.esFresco,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<String>(cantidad.value);
    }
    if (fechaCaducidad.present) {
      map['fecha_caducidad'] = Variable<String>(fechaCaducidad.value);
    }
    if (esFresco.present) {
      map['es_fresco'] = Variable<bool>(esFresco.value);
    }
    if (codigoBarras.present) {
      map['codigo_barras'] = Variable<String>(codigoBarras.value);
    }
    if (imagenUrl.present) {
      map['imagen_url'] = Variable<String>(imagenUrl.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nombre: $nombre, ')
          ..write('emoji: $emoji, ')
          ..write('categoria: $categoria, ')
          ..write('cantidad: $cantidad, ')
          ..write('fechaCaducidad: $fechaCaducidad, ')
          ..write('esFresco: $esFresco, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('imagenUrl: $imagenUrl, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductosTableTable productosTable = $ProductosTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [productosTable];
}

typedef $$ProductosTableTableCreateCompanionBuilder =
    ProductosTableCompanion Function({
      required String id,
      required String userId,
      required String nombre,
      required String emoji,
      required String categoria,
      required String cantidad,
      required String fechaCaducidad,
      required bool esFresco,
      Value<String?> codigoBarras,
      Value<String?> imagenUrl,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ProductosTableTableUpdateCompanionBuilder =
    ProductosTableCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> nombre,
      Value<String> emoji,
      Value<String> categoria,
      Value<String> cantidad,
      Value<String> fechaCaducidad,
      Value<bool> esFresco,
      Value<String?> codigoBarras,
      Value<String?> imagenUrl,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ProductosTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaCaducidad => $composableBuilder(
    column: $table.fechaCaducidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esFresco => $composableBuilder(
    column: $table.esFresco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagenUrl => $composableBuilder(
    column: $table.imagenUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaCaducidad => $composableBuilder(
    column: $table.fechaCaducidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esFresco => $composableBuilder(
    column: $table.esFresco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagenUrl => $composableBuilder(
    column: $table.imagenUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTableTable> {
  $$ProductosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<String> get fechaCaducidad => $composableBuilder(
    column: $table.fechaCaducidad,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get esFresco =>
      $composableBuilder(column: $table.esFresco, builder: (column) => column);

  GeneratedColumn<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagenUrl =>
      $composableBuilder(column: $table.imagenUrl, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ProductosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTableTable,
          ProductosTableData,
          $$ProductosTableTableFilterComposer,
          $$ProductosTableTableOrderingComposer,
          $$ProductosTableTableAnnotationComposer,
          $$ProductosTableTableCreateCompanionBuilder,
          $$ProductosTableTableUpdateCompanionBuilder,
          (
            ProductosTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductosTableTable,
              ProductosTableData
            >,
          ),
          ProductosTableData,
          PrefetchHooks Function()
        > {
  $$ProductosTableTableTableManager(
    _$AppDatabase db,
    $ProductosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> cantidad = const Value.absent(),
                Value<String> fechaCaducidad = const Value.absent(),
                Value<bool> esFresco = const Value.absent(),
                Value<String?> codigoBarras = const Value.absent(),
                Value<String?> imagenUrl = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosTableCompanion(
                id: id,
                userId: userId,
                nombre: nombre,
                emoji: emoji,
                categoria: categoria,
                cantidad: cantidad,
                fechaCaducidad: fechaCaducidad,
                esFresco: esFresco,
                codigoBarras: codigoBarras,
                imagenUrl: imagenUrl,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String nombre,
                required String emoji,
                required String categoria,
                required String cantidad,
                required String fechaCaducidad,
                required bool esFresco,
                Value<String?> codigoBarras = const Value.absent(),
                Value<String?> imagenUrl = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosTableCompanion.insert(
                id: id,
                userId: userId,
                nombre: nombre,
                emoji: emoji,
                categoria: categoria,
                cantidad: cantidad,
                fechaCaducidad: fechaCaducidad,
                esFresco: esFresco,
                codigoBarras: codigoBarras,
                imagenUrl: imagenUrl,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTableTable,
      ProductosTableData,
      $$ProductosTableTableFilterComposer,
      $$ProductosTableTableOrderingComposer,
      $$ProductosTableTableAnnotationComposer,
      $$ProductosTableTableCreateCompanionBuilder,
      $$ProductosTableTableUpdateCompanionBuilder,
      (
        ProductosTableData,
        BaseReferences<_$AppDatabase, $ProductosTableTable, ProductosTableData>,
      ),
      ProductosTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductosTableTableTableManager get productosTable =>
      $$ProductosTableTableTableManager(_db, _db.productosTable);
}
