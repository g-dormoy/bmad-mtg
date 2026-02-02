// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CardsTableTable extends CardsTable
    with TableInfo<$CardsTableTable, CardEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _scryfallIdMeta =
      const VerificationMeta('scryfallId');
  @override
  late final GeneratedColumn<String> scryfallId = GeneratedColumn<String>(
      'scryfall_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _oracleTextMeta =
      const VerificationMeta('oracleText');
  @override
  late final GeneratedColumn<String> oracleText = GeneratedColumn<String>(
      'oracle_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _manaCostMeta =
      const VerificationMeta('manaCost');
  @override
  late final GeneratedColumn<String> manaCost = GeneratedColumn<String>(
      'mana_cost', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorsMeta = const VerificationMeta('colors');
  @override
  late final GeneratedColumn<String> colors = GeneratedColumn<String>(
      'colors', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _setCodeMeta =
      const VerificationMeta('setCode');
  @override
  late final GeneratedColumn<String> setCode = GeneratedColumn<String>(
      'set_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        scryfallId,
        name,
        type,
        oracleText,
        manaCost,
        colors,
        setCode,
        imagePath,
        quantity,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(Insertable<CardEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scryfall_id')) {
      context.handle(
          _scryfallIdMeta,
          scryfallId.isAcceptableOrUnknown(
              data['scryfall_id']!, _scryfallIdMeta));
    } else if (isInserting) {
      context.missing(_scryfallIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('oracle_text')) {
      context.handle(_oracleTextMeta,
          oracleText.isAcceptableOrUnknown(data['oracle_text']!, _oracleTextMeta));
    }
    if (data.containsKey('mana_cost')) {
      context.handle(_manaCostMeta,
          manaCost.isAcceptableOrUnknown(data['mana_cost']!, _manaCostMeta));
    }
    if (data.containsKey('colors')) {
      context.handle(_colorsMeta,
          colors.isAcceptableOrUnknown(data['colors']!, _colorsMeta));
    }
    if (data.containsKey('set_code')) {
      context.handle(_setCodeMeta,
          setCode.isAcceptableOrUnknown(data['set_code']!, _setCodeMeta));
    } else if (isInserting) {
      context.missing(_setCodeMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scryfallId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scryfall_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      oracleText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}oracle_text']),
      manaCost: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mana_cost']),
      colors: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}colors']),
      setCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_code'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CardsTableTable createAlias(String alias) {
    return $CardsTableTable(attachedDatabase, alias);
  }
}

class CardEntity extends DataClass implements Insertable<CardEntity> {
  final int id;
  final String scryfallId;
  final String name;
  final String type;
  final String? oracleText;
  final String? manaCost;
  final String? colors;
  final String setCode;
  final String? imagePath;
  final int quantity;
  final DateTime createdAt;
  const CardEntity(
      {required this.id,
      required this.scryfallId,
      required this.name,
      required this.type,
      this.oracleText,
      this.manaCost,
      this.colors,
      required this.setCode,
      this.imagePath,
      required this.quantity,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scryfall_id'] = Variable<String>(scryfallId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || oracleText != null) {
      map['oracle_text'] = Variable<String>(oracleText);
    }
    if (!nullToAbsent || manaCost != null) {
      map['mana_cost'] = Variable<String>(manaCost);
    }
    if (!nullToAbsent || colors != null) {
      map['colors'] = Variable<String>(colors);
    }
    map['set_code'] = Variable<String>(setCode);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['quantity'] = Variable<int>(quantity);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardsTableCompanion toCompanion(bool nullToAbsent) {
    return CardsTableCompanion(
      id: Value(id),
      scryfallId: Value(scryfallId),
      name: Value(name),
      type: Value(type),
      oracleText: oracleText == null && nullToAbsent
          ? const Value.absent()
          : Value(oracleText),
      manaCost: manaCost == null && nullToAbsent
          ? const Value.absent()
          : Value(manaCost),
      colors:
          colors == null && nullToAbsent ? const Value.absent() : Value(colors),
      setCode: Value(setCode),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      quantity: Value(quantity),
      createdAt: Value(createdAt),
    );
  }

  factory CardEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardEntity(
      id: serializer.fromJson<int>(json['id']),
      scryfallId: serializer.fromJson<String>(json['scryfallId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      oracleText: serializer.fromJson<String?>(json['oracleText']),
      manaCost: serializer.fromJson<String?>(json['manaCost']),
      colors: serializer.fromJson<String?>(json['colors']),
      setCode: serializer.fromJson<String>(json['setCode']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      quantity: serializer.fromJson<int>(json['quantity']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scryfallId': serializer.toJson<String>(scryfallId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'oracleText': serializer.toJson<String?>(oracleText),
      'manaCost': serializer.toJson<String?>(manaCost),
      'colors': serializer.toJson<String?>(colors),
      'setCode': serializer.toJson<String>(setCode),
      'imagePath': serializer.toJson<String?>(imagePath),
      'quantity': serializer.toJson<int>(quantity),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardEntity copyWith(
          {int? id,
          String? scryfallId,
          String? name,
          String? type,
          Value<String?> oracleText = const Value.absent(),
          Value<String?> manaCost = const Value.absent(),
          Value<String?> colors = const Value.absent(),
          String? setCode,
          Value<String?> imagePath = const Value.absent(),
          int? quantity,
          DateTime? createdAt}) =>
      CardEntity(
        id: id ?? this.id,
        scryfallId: scryfallId ?? this.scryfallId,
        name: name ?? this.name,
        type: type ?? this.type,
        oracleText: oracleText.present ? oracleText.value : this.oracleText,
        manaCost: manaCost.present ? manaCost.value : this.manaCost,
        colors: colors.present ? colors.value : this.colors,
        setCode: setCode ?? this.setCode,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        quantity: quantity ?? this.quantity,
        createdAt: createdAt ?? this.createdAt,
      );
  CardEntity copyWithCompanion(CardsTableCompanion data) {
    return CardEntity(
      id: data.id.present ? data.id.value : this.id,
      scryfallId:
          data.scryfallId.present ? data.scryfallId.value : this.scryfallId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      oracleText:
          data.oracleText.present ? data.oracleText.value : this.oracleText,
      manaCost: data.manaCost.present ? data.manaCost.value : this.manaCost,
      colors: data.colors.present ? data.colors.value : this.colors,
      setCode: data.setCode.present ? data.setCode.value : this.setCode,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardEntity(')
          ..write('id: $id, ')
          ..write('scryfallId: $scryfallId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('oracleText: $oracleText, ')
          ..write('manaCost: $manaCost, ')
          ..write('colors: $colors, ')
          ..write('setCode: $setCode, ')
          ..write('imagePath: $imagePath, ')
          ..write('quantity: $quantity, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scryfallId, name, type, oracleText,
      manaCost, colors, setCode, imagePath, quantity, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardEntity &&
          other.id == this.id &&
          other.scryfallId == this.scryfallId &&
          other.name == this.name &&
          other.type == this.type &&
          other.oracleText == this.oracleText &&
          other.manaCost == this.manaCost &&
          other.colors == this.colors &&
          other.setCode == this.setCode &&
          other.imagePath == this.imagePath &&
          other.quantity == this.quantity &&
          other.createdAt == this.createdAt);
}

class CardsTableCompanion extends UpdateCompanion<CardEntity> {
  final Value<int> id;
  final Value<String> scryfallId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> oracleText;
  final Value<String?> manaCost;
  final Value<String?> colors;
  final Value<String> setCode;
  final Value<String?> imagePath;
  final Value<int> quantity;
  final Value<DateTime> createdAt;
  const CardsTableCompanion({
    this.id = const Value.absent(),
    this.scryfallId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.oracleText = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.colors = const Value.absent(),
    this.setCode = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.quantity = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CardsTableCompanion.insert({
    this.id = const Value.absent(),
    required String scryfallId,
    required String name,
    required String type,
    this.oracleText = const Value.absent(),
    this.manaCost = const Value.absent(),
    this.colors = const Value.absent(),
    required String setCode,
    this.imagePath = const Value.absent(),
    this.quantity = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : scryfallId = Value(scryfallId),
        name = Value(name),
        type = Value(type),
        setCode = Value(setCode);
  static Insertable<CardEntity> custom({
    Expression<int>? id,
    Expression<String>? scryfallId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? oracleText,
    Expression<String>? manaCost,
    Expression<String>? colors,
    Expression<String>? setCode,
    Expression<String>? imagePath,
    Expression<int>? quantity,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scryfallId != null) 'scryfall_id': scryfallId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (oracleText != null) 'oracle_text': oracleText,
      if (manaCost != null) 'mana_cost': manaCost,
      if (colors != null) 'colors': colors,
      if (setCode != null) 'set_code': setCode,
      if (imagePath != null) 'image_path': imagePath,
      if (quantity != null) 'quantity': quantity,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CardsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? scryfallId,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? oracleText,
      Value<String?>? manaCost,
      Value<String?>? colors,
      Value<String>? setCode,
      Value<String?>? imagePath,
      Value<int>? quantity,
      Value<DateTime>? createdAt}) {
    return CardsTableCompanion(
      id: id ?? this.id,
      scryfallId: scryfallId ?? this.scryfallId,
      name: name ?? this.name,
      type: type ?? this.type,
      oracleText: oracleText ?? this.oracleText,
      manaCost: manaCost ?? this.manaCost,
      colors: colors ?? this.colors,
      setCode: setCode ?? this.setCode,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scryfallId.present) {
      map['scryfall_id'] = Variable<String>(scryfallId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (oracleText.present) {
      map['oracle_text'] = Variable<String>(oracleText.value);
    }
    if (manaCost.present) {
      map['mana_cost'] = Variable<String>(manaCost.value);
    }
    if (colors.present) {
      map['colors'] = Variable<String>(colors.value);
    }
    if (setCode.present) {
      map['set_code'] = Variable<String>(setCode.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsTableCompanion(')
          ..write('id: $id, ')
          ..write('scryfallId: $scryfallId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('oracleText: $oracleText, ')
          ..write('manaCost: $manaCost, ')
          ..write('colors: $colors, ')
          ..write('setCode: $setCode, ')
          ..write('imagePath: $imagePath, ')
          ..write('quantity: $quantity, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardsTableTable cardsTable = $CardsTableTable(this);
  late final CardsDao cardsDao = CardsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cardsTable];
}

typedef $$CardsTableTableCreateCompanionBuilder = CardsTableCompanion Function({
  Value<int> id,
  required String scryfallId,
  required String name,
  required String type,
  Value<String?> oracleText,
  Value<String?> manaCost,
  Value<String?> colors,
  required String setCode,
  Value<String?> imagePath,
  Value<int> quantity,
  Value<DateTime> createdAt,
});
typedef $$CardsTableTableUpdateCompanionBuilder = CardsTableCompanion Function({
  Value<int> id,
  Value<String> scryfallId,
  Value<String> name,
  Value<String> type,
  Value<String?> oracleText,
  Value<String?> manaCost,
  Value<String?> colors,
  Value<String> setCode,
  Value<String?> imagePath,
  Value<int> quantity,
  Value<DateTime> createdAt,
});

class $$CardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CardsTableTable> {
  $$CardsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scryfallId => $composableBuilder(
      column: $table.scryfallId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get oracleText => $composableBuilder(
      column: $table.oracleText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manaCost => $composableBuilder(
      column: $table.manaCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colors => $composableBuilder(
      column: $table.colors, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setCode => $composableBuilder(
      column: $table.setCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTableTable> {
  $$CardsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scryfallId => $composableBuilder(
      column: $table.scryfallId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get oracleText => $composableBuilder(
      column: $table.oracleText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manaCost => $composableBuilder(
      column: $table.manaCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colors => $composableBuilder(
      column: $table.colors, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setCode => $composableBuilder(
      column: $table.setCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTableTable> {
  $$CardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scryfallId => $composableBuilder(
      column: $table.scryfallId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get oracleText =>
      $composableBuilder(column: $table.oracleText, builder: (column) => column);

  GeneratedColumn<String> get manaCost =>
      $composableBuilder(column: $table.manaCost, builder: (column) => column);

  GeneratedColumn<String> get colors =>
      $composableBuilder(column: $table.colors, builder: (column) => column);

  GeneratedColumn<String> get setCode =>
      $composableBuilder(column: $table.setCode, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CardsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardsTableTable,
    CardEntity,
    $$CardsTableTableFilterComposer,
    $$CardsTableTableOrderingComposer,
    $$CardsTableTableAnnotationComposer,
    $$CardsTableTableCreateCompanionBuilder,
    $$CardsTableTableUpdateCompanionBuilder,
    (CardEntity, BaseReferences<_$AppDatabase, $CardsTableTable, CardEntity>),
    CardEntity,
    PrefetchHooks Function()> {
  $$CardsTableTableTableManager(_$AppDatabase db, $CardsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> scryfallId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> oracleText = const Value.absent(),
            Value<String?> manaCost = const Value.absent(),
            Value<String?> colors = const Value.absent(),
            Value<String> setCode = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CardsTableCompanion(
            id: id,
            scryfallId: scryfallId,
            name: name,
            type: type,
            oracleText: oracleText,
            manaCost: manaCost,
            colors: colors,
            setCode: setCode,
            imagePath: imagePath,
            quantity: quantity,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String scryfallId,
            required String name,
            required String type,
            Value<String?> oracleText = const Value.absent(),
            Value<String?> manaCost = const Value.absent(),
            Value<String?> colors = const Value.absent(),
            required String setCode,
            Value<String?> imagePath = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CardsTableCompanion.insert(
            id: id,
            scryfallId: scryfallId,
            name: name,
            type: type,
            oracleText: oracleText,
            manaCost: manaCost,
            colors: colors,
            setCode: setCode,
            imagePath: imagePath,
            quantity: quantity,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardsTableTable,
    CardEntity,
    $$CardsTableTableFilterComposer,
    $$CardsTableTableOrderingComposer,
    $$CardsTableTableAnnotationComposer,
    $$CardsTableTableCreateCompanionBuilder,
    $$CardsTableTableUpdateCompanionBuilder,
    (CardEntity, BaseReferences<_$AppDatabase, $CardsTableTable, CardEntity>),
    CardEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardsTableTableTableManager get cardsTable =>
      $$CardsTableTableTableManager(_db, _db.cardsTable);
}
