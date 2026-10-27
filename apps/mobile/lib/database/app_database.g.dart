// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PhotosTable extends Photos with TableInfo<$PhotosTable, PhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, uuid, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class PhotoRow extends DataClass implements Insertable<PhotoRow> {
  final int id;
  final String uuid;
  final String path;
  const PhotoRow({required this.id, required this.uuid, required this.path});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['path'] = Variable<String>(path);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(id: Value(id), uuid: Value(uuid), path: Value(path));
  }

  factory PhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      path: serializer.fromJson<String>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'path': serializer.toJson<String>(path),
    };
  }

  PhotoRow copyWith({int? id, String? uuid, String? path}) => PhotoRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    path: path ?? this.path,
  );
  PhotoRow copyWithCompanion(PhotosCompanion data) {
    return PhotoRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.path == this.path);
}

class PhotosCompanion extends UpdateCompanion<PhotoRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> path;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.path = const Value.absent(),
  });
  PhotosCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String path,
  }) : uuid = Value(uuid),
       path = Value(path);
  static Insertable<PhotoRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? path,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (path != null) 'path': path,
    });
  }

  PhotosCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? path,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      path: path ?? this.path,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, RecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _portionsMeta = const VerificationMeta(
    'portions',
  );
  @override
  late final GeneratedColumn<int> portions = GeneratedColumn<int>(
    'portions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _procedureMeta = const VerificationMeta(
    'procedure',
  );
  @override
  late final GeneratedColumn<String> procedure = GeneratedColumn<String>(
    'procedure',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES photos (uuid)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    title,
    portions,
    procedure,
    photoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('portions')) {
      context.handle(
        _portionsMeta,
        portions.isAcceptableOrUnknown(data['portions']!, _portionsMeta),
      );
    } else if (isInserting) {
      context.missing(_portionsMeta);
    }
    if (data.containsKey('procedure')) {
      context.handle(
        _procedureMeta,
        procedure.isAcceptableOrUnknown(data['procedure']!, _procedureMeta),
      );
    }
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      portions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}portions'],
      )!,
      procedure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}procedure'],
      ),
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      ),
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class RecipeRow extends DataClass implements Insertable<RecipeRow> {
  final int id;
  final String uuid;
  final String title;
  final int portions;
  final String? procedure;
  final String? photoId;
  const RecipeRow({
    required this.id,
    required this.uuid,
    required this.title,
    required this.portions,
    this.procedure,
    this.photoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    map['portions'] = Variable<int>(portions);
    if (!nullToAbsent || procedure != null) {
      map['procedure'] = Variable<String>(procedure);
    }
    if (!nullToAbsent || photoId != null) {
      map['photo_id'] = Variable<String>(photoId);
    }
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      uuid: Value(uuid),
      title: Value(title),
      portions: Value(portions),
      procedure: procedure == null && nullToAbsent
          ? const Value.absent()
          : Value(procedure),
      photoId: photoId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoId),
    );
  }

  factory RecipeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      portions: serializer.fromJson<int>(json['portions']),
      procedure: serializer.fromJson<String?>(json['procedure']),
      photoId: serializer.fromJson<String?>(json['photoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'portions': serializer.toJson<int>(portions),
      'procedure': serializer.toJson<String?>(procedure),
      'photoId': serializer.toJson<String?>(photoId),
    };
  }

  RecipeRow copyWith({
    int? id,
    String? uuid,
    String? title,
    int? portions,
    Value<String?> procedure = const Value.absent(),
    Value<String?> photoId = const Value.absent(),
  }) => RecipeRow(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    title: title ?? this.title,
    portions: portions ?? this.portions,
    procedure: procedure.present ? procedure.value : this.procedure,
    photoId: photoId.present ? photoId.value : this.photoId,
  );
  RecipeRow copyWithCompanion(RecipesCompanion data) {
    return RecipeRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      portions: data.portions.present ? data.portions.value : this.portions,
      procedure: data.procedure.present ? data.procedure.value : this.procedure,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('portions: $portions, ')
          ..write('procedure: $procedure, ')
          ..write('photoId: $photoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, title, portions, procedure, photoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.portions == this.portions &&
          other.procedure == this.procedure &&
          other.photoId == this.photoId);
}

class RecipesCompanion extends UpdateCompanion<RecipeRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> title;
  final Value<int> portions;
  final Value<String?> procedure;
  final Value<String?> photoId;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.portions = const Value.absent(),
    this.procedure = const Value.absent(),
    this.photoId = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String title,
    required int portions,
    this.procedure = const Value.absent(),
    this.photoId = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       portions = Value(portions);
  static Insertable<RecipeRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<int>? portions,
    Expression<String>? procedure,
    Expression<String>? photoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (portions != null) 'portions': portions,
      if (procedure != null) 'procedure': procedure,
      if (photoId != null) 'photo_id': photoId,
    });
  }

  RecipesCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? title,
    Value<int>? portions,
    Value<String?>? procedure,
    Value<String?>? photoId,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      portions: portions ?? this.portions,
      procedure: procedure ?? this.procedure,
      photoId: photoId ?? this.photoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (portions.present) {
      map['portions'] = Variable<int>(portions.value);
    }
    if (procedure.present) {
      map['procedure'] = Variable<String>(procedure.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('portions: $portions, ')
          ..write('procedure: $procedure, ')
          ..write('photoId: $photoId')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, IngredientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    position,
    name,
    quantity,
    unit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<IngredientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IngredientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IngredientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class IngredientRow extends DataClass implements Insertable<IngredientRow> {
  final int id;
  final int recipeId;
  final int position;
  final String name;
  final double quantity;
  final String unit;
  const IngredientRow({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.name,
    required this.quantity,
    required this.unit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      name: Value(name),
      quantity: Value(quantity),
      unit: Value(unit),
    );
  }

  factory IngredientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IngredientRow(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
    };
  }

  IngredientRow copyWith({
    int? id,
    int? recipeId,
    int? position,
    String? name,
    double? quantity,
    String? unit,
  }) => IngredientRow(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
  );
  IngredientRow copyWithCompanion(RecipeIngredientsCompanion data) {
    return IngredientRow(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IngredientRow(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, position, name, quantity, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IngredientRow &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit);
}

class RecipeIngredientsCompanion extends UpdateCompanion<IngredientRow> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int> position;
  final Value<String> name;
  final Value<double> quantity;
  final Value<String> unit;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required int position,
    required String name,
    required double quantity,
    required String unit,
  }) : recipeId = Value(recipeId),
       position = Value(position),
       name = Value(name),
       quantity = Value(quantity),
       unit = Value(unit);
  static Insertable<IngredientRow> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<int>? id,
    Value<int>? recipeId,
    Value<int>? position,
    Value<String>? name,
    Value<double>? quantity,
    Value<String>? unit,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }
}

class $RecipeCategoriesTable extends RecipeCategories
    with TableInfo<$RecipeCategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<int> recipeId = GeneratedColumn<int>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, recipeId, position, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $RecipeCategoriesTable createAlias(String alias) {
    return $RecipeCategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final int recipeId;
  final int position;
  final String name;
  const CategoryRow({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<int>(recipeId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    return map;
  }

  RecipeCategoriesCompanion toCompanion(bool nullToAbsent) {
    return RecipeCategoriesCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      name: Value(name),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<int>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<int>(recipeId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
    };
  }

  CategoryRow copyWith({int? id, int? recipeId, int? position, String? name}) =>
      CategoryRow(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        position: position ?? this.position,
        name: name ?? this.name,
      );
  CategoryRow copyWithCompanion(RecipeCategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, position, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.name == this.name);
}

class RecipeCategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<int> recipeId;
  final Value<int> position;
  final Value<String> name;
  const RecipeCategoriesCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
  });
  RecipeCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int recipeId,
    required int position,
    required String name,
  }) : recipeId = Value(recipeId),
       position = Value(position),
       name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<int>? recipeId,
    Expression<int>? position,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
    });
  }

  RecipeCategoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? recipeId,
    Value<int>? position,
    Value<String>? name,
  }) {
    return RecipeCategoriesCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<int>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $GroceryListsTable extends GroceryLists
    with TableInfo<$GroceryListsTable, GroceryListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroceryListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, uuid, weekStart];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grocery_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroceryListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroceryListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroceryListRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
    );
  }

  @override
  $GroceryListsTable createAlias(String alias) {
    return $GroceryListsTable(attachedDatabase, alias);
  }
}

class GroceryListRow extends DataClass implements Insertable<GroceryListRow> {
  final int id;
  final String uuid;
  final String weekStart;
  const GroceryListRow({
    required this.id,
    required this.uuid,
    required this.weekStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['week_start'] = Variable<String>(weekStart);
    return map;
  }

  GroceryListsCompanion toCompanion(bool nullToAbsent) {
    return GroceryListsCompanion(
      id: Value(id),
      uuid: Value(uuid),
      weekStart: Value(weekStart),
    );
  }

  factory GroceryListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroceryListRow(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      weekStart: serializer.fromJson<String>(json['weekStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'weekStart': serializer.toJson<String>(weekStart),
    };
  }

  GroceryListRow copyWith({int? id, String? uuid, String? weekStart}) =>
      GroceryListRow(
        id: id ?? this.id,
        uuid: uuid ?? this.uuid,
        weekStart: weekStart ?? this.weekStart,
      );
  GroceryListRow copyWithCompanion(GroceryListsCompanion data) {
    return GroceryListRow(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroceryListRow(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('weekStart: $weekStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, weekStart);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroceryListRow &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.weekStart == this.weekStart);
}

class GroceryListsCompanion extends UpdateCompanion<GroceryListRow> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> weekStart;
  const GroceryListsCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.weekStart = const Value.absent(),
  });
  GroceryListsCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String weekStart,
  }) : uuid = Value(uuid),
       weekStart = Value(weekStart);
  static Insertable<GroceryListRow> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? weekStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (weekStart != null) 'week_start': weekStart,
    });
  }

  GroceryListsCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? weekStart,
  }) {
    return GroceryListsCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroceryListsCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('weekStart: $weekStart')
          ..write(')'))
        .toString();
  }
}

class $GroceryListRecipesTable extends GroceryListRecipes
    with TableInfo<$GroceryListRecipesTable, GroceryListRecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroceryListRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grocery_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, listId, position, title];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grocery_list_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroceryListRecipeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroceryListRecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroceryListRecipeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
    );
  }

  @override
  $GroceryListRecipesTable createAlias(String alias) {
    return $GroceryListRecipesTable(attachedDatabase, alias);
  }
}

class GroceryListRecipeRow extends DataClass
    implements Insertable<GroceryListRecipeRow> {
  final int id;
  final int listId;
  final int position;
  final String title;
  const GroceryListRecipeRow({
    required this.id,
    required this.listId,
    required this.position,
    required this.title,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['position'] = Variable<int>(position);
    map['title'] = Variable<String>(title);
    return map;
  }

  GroceryListRecipesCompanion toCompanion(bool nullToAbsent) {
    return GroceryListRecipesCompanion(
      id: Value(id),
      listId: Value(listId),
      position: Value(position),
      title: Value(title),
    );
  }

  factory GroceryListRecipeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroceryListRecipeRow(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      position: serializer.fromJson<int>(json['position']),
      title: serializer.fromJson<String>(json['title']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'position': serializer.toJson<int>(position),
      'title': serializer.toJson<String>(title),
    };
  }

  GroceryListRecipeRow copyWith({
    int? id,
    int? listId,
    int? position,
    String? title,
  }) => GroceryListRecipeRow(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    position: position ?? this.position,
    title: title ?? this.title,
  );
  GroceryListRecipeRow copyWithCompanion(GroceryListRecipesCompanion data) {
    return GroceryListRecipeRow(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      position: data.position.present ? data.position.value : this.position,
      title: data.title.present ? data.title.value : this.title,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroceryListRecipeRow(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('position: $position, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, position, title);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroceryListRecipeRow &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.position == this.position &&
          other.title == this.title);
}

class GroceryListRecipesCompanion
    extends UpdateCompanion<GroceryListRecipeRow> {
  final Value<int> id;
  final Value<int> listId;
  final Value<int> position;
  final Value<String> title;
  const GroceryListRecipesCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.position = const Value.absent(),
    this.title = const Value.absent(),
  });
  GroceryListRecipesCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required int position,
    required String title,
  }) : listId = Value(listId),
       position = Value(position),
       title = Value(title);
  static Insertable<GroceryListRecipeRow> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<int>? position,
    Expression<String>? title,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (position != null) 'position': position,
      if (title != null) 'title': title,
    });
  }

  GroceryListRecipesCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<int>? position,
    Value<String>? title,
  }) {
    return GroceryListRecipesCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      position: position ?? this.position,
      title: title ?? this.title,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroceryListRecipesCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('position: $position, ')
          ..write('title: $title')
          ..write(')'))
        .toString();
  }
}

class $GroceryListItemsTable extends GroceryListItems
    with TableInfo<$GroceryListItemsTable, GroceryListItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroceryListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grocery_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tickedMeta = const VerificationMeta('ticked');
  @override
  late final GeneratedColumn<bool> ticked = GeneratedColumn<bool>(
    'ticked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ticked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    position,
    name,
    quantity,
    unit,
    ticked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grocery_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroceryListItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('ticked')) {
      context.handle(
        _tickedMeta,
        ticked.isAcceptableOrUnknown(data['ticked']!, _tickedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroceryListItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroceryListItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      ticked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ticked'],
      )!,
    );
  }

  @override
  $GroceryListItemsTable createAlias(String alias) {
    return $GroceryListItemsTable(attachedDatabase, alias);
  }
}

class GroceryListItemRow extends DataClass
    implements Insertable<GroceryListItemRow> {
  final int id;
  final int listId;
  final int position;
  final String name;
  final double quantity;
  final String unit;
  final bool ticked;
  const GroceryListItemRow({
    required this.id,
    required this.listId,
    required this.position,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.ticked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_id'] = Variable<int>(listId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<double>(quantity);
    map['unit'] = Variable<String>(unit);
    map['ticked'] = Variable<bool>(ticked);
    return map;
  }

  GroceryListItemsCompanion toCompanion(bool nullToAbsent) {
    return GroceryListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      position: Value(position),
      name: Value(name),
      quantity: Value(quantity),
      unit: Value(unit),
      ticked: Value(ticked),
    );
  }

  factory GroceryListItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroceryListItemRow(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int>(json['listId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      ticked: serializer.fromJson<bool>(json['ticked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int>(listId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(unit),
      'ticked': serializer.toJson<bool>(ticked),
    };
  }

  GroceryListItemRow copyWith({
    int? id,
    int? listId,
    int? position,
    String? name,
    double? quantity,
    String? unit,
    bool? ticked,
  }) => GroceryListItemRow(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    position: position ?? this.position,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    ticked: ticked ?? this.ticked,
  );
  GroceryListItemRow copyWithCompanion(GroceryListItemsCompanion data) {
    return GroceryListItemRow(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      ticked: data.ticked.present ? data.ticked.value : this.ticked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroceryListItemRow(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('ticked: $ticked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, listId, position, name, quantity, unit, ticked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroceryListItemRow &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.position == this.position &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.ticked == this.ticked);
}

class GroceryListItemsCompanion extends UpdateCompanion<GroceryListItemRow> {
  final Value<int> id;
  final Value<int> listId;
  final Value<int> position;
  final Value<String> name;
  final Value<double> quantity;
  final Value<String> unit;
  final Value<bool> ticked;
  const GroceryListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.ticked = const Value.absent(),
  });
  GroceryListItemsCompanion.insert({
    this.id = const Value.absent(),
    required int listId,
    required int position,
    required String name,
    required double quantity,
    required String unit,
    this.ticked = const Value.absent(),
  }) : listId = Value(listId),
       position = Value(position),
       name = Value(name),
       quantity = Value(quantity),
       unit = Value(unit);
  static Insertable<GroceryListItemRow> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<bool>? ticked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (ticked != null) 'ticked': ticked,
    });
  }

  GroceryListItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? listId,
    Value<int>? position,
    Value<String>? name,
    Value<double>? quantity,
    Value<String>? unit,
    Value<bool>? ticked,
  }) {
    return GroceryListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      position: position ?? this.position,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      ticked: ticked ?? this.ticked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (ticked.present) {
      map['ticked'] = Variable<bool>(ticked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroceryListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('ticked: $ticked')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $RecipeCategoriesTable recipeCategories = $RecipeCategoriesTable(
    this,
  );
  late final $GroceryListsTable groceryLists = $GroceryListsTable(this);
  late final $GroceryListRecipesTable groceryListRecipes =
      $GroceryListRecipesTable(this);
  late final $GroceryListItemsTable groceryListItems = $GroceryListItemsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    photos,
    recipes,
    recipeIngredients,
    recipeCategories,
    groceryLists,
    groceryListRecipes,
    groceryListItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_ingredients', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recipes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recipe_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grocery_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grocery_list_recipes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grocery_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grocery_list_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      Value<int> id,
      required String uuid,
      required String path,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> path,
    });

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipesTable, List<RecipeRow>> _recipesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.recipes,
    aliasName: 'photos__uuid__recipes__photo_id',
  );

  $$RecipesTableProcessedTableManager get recipesRefs {
    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.photoId.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_recipesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipesRefs(
    Expression<bool> Function($$RecipesTableFilterComposer f) f,
  ) {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  Expression<T> recipesRefs<T extends Object>(
    Expression<T> Function($$RecipesTableAnnotationComposer a) f,
  ) {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          PhotoRow,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (PhotoRow, $$PhotosTableReferences),
          PhotoRow,
          PrefetchHooks Function({bool recipesRefs})
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> path = const Value.absent(),
              }) => PhotosCompanion(id: id, uuid: uuid, path: path),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String path,
              }) => PhotosCompanion.insert(id: id, uuid: uuid, path: path),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PhotosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({recipesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (recipesRefs) db.recipes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recipesRefs)
                    await $_getPrefetchedData<
                      PhotoRow,
                      $PhotosTable,
                      RecipeRow
                    >(
                      currentTable: table,
                      referencedTable: $$PhotosTableReferences
                          ._recipesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PhotosTableReferences(db, table, p0).recipesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.photoId == item.uuid),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      PhotoRow,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (PhotoRow, $$PhotosTableReferences),
      PhotoRow,
      PrefetchHooks Function({bool recipesRefs})
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      required String uuid,
      required String title,
      required int portions,
      Value<String?> procedure,
      Value<String?> photoId,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> title,
      Value<int> portions,
      Value<String?> procedure,
      Value<String?> photoId,
    });

final class $$RecipesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PhotosTable _photoIdTable(_$AppDatabase db) =>
      db.photos.createAlias('recipes__photo_id__photos__uuid');

  $$PhotosTableProcessedTableManager? get photoId {
    final $_column = $_itemColumn<String>('photo_id');
    if ($_column == null) return null;
    final manager = $$PhotosTableTableManager(
      $_db,
      $_db.photos,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_photoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RecipeIngredientsTable, List<IngredientRow>>
  _recipeIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: 'recipes__id__recipe_ingredients__recipe_id',
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager = $$RecipeIngredientsTableTableManager(
      $_db,
      $_db.recipeIngredients,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeCategoriesTable, List<CategoryRow>>
  _recipeCategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeCategories,
    aliasName: 'recipes__id__recipe_categories__recipe_id',
  );

  $$RecipeCategoriesTableProcessedTableManager get recipeCategoriesRefs {
    final manager = $$RecipeCategoriesTableTableManager(
      $_db,
      $_db.recipeCategories,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get portions => $composableBuilder(
    column: $table.portions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnFilters(column),
  );

  $$PhotosTableFilterComposer get photoId {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeCategoriesRefs(
    Expression<bool> Function($$RecipeCategoriesTableFilterComposer f) f,
  ) {
    final $$RecipeCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeCategories,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.recipeCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get portions => $composableBuilder(
    column: $table.portions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get procedure => $composableBuilder(
    column: $table.procedure,
    builder: (column) => ColumnOrderings(column),
  );

  $$PhotosTableOrderingComposer get photoId {
    final $$PhotosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableOrderingComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get portions =>
      $composableBuilder(column: $table.portions, builder: (column) => column);

  GeneratedColumn<String> get procedure =>
      $composableBuilder(column: $table.procedure, builder: (column) => column);

  $$PhotosTableAnnotationComposer get photoId {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.recipeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recipeCategoriesRefs<T extends Object>(
    Expression<T> Function($$RecipeCategoriesTableAnnotationComposer a) f,
  ) {
    final $$RecipeCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeCategories,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          RecipeRow,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (RecipeRow, $$RecipesTableReferences),
          RecipeRow,
          PrefetchHooks Function({
            bool photoId,
            bool recipeIngredientsRefs,
            bool recipeCategoriesRefs,
          })
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> portions = const Value.absent(),
                Value<String?> procedure = const Value.absent(),
                Value<String?> photoId = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                uuid: uuid,
                title: title,
                portions: portions,
                procedure: procedure,
                photoId: photoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String title,
                required int portions,
                Value<String?> procedure = const Value.absent(),
                Value<String?> photoId = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                uuid: uuid,
                title: title,
                portions: portions,
                procedure: procedure,
                photoId: photoId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                photoId = false,
                recipeIngredientsRefs = false,
                recipeCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeIngredientsRefs) db.recipeIngredients,
                    if (recipeCategoriesRefs) db.recipeCategories,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (photoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.photoId,
                                    referencedTable: $$RecipesTableReferences
                                        ._photoIdTable(db),
                                    referencedColumn: $$RecipesTableReferences
                                        ._photoIdTable(db)
                                        .uuid,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeIngredientsRefs)
                        await $_getPrefetchedData<
                          RecipeRow,
                          $RecipesTable,
                          IngredientRow
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeCategoriesRefs)
                        await $_getPrefetchedData<
                          RecipeRow,
                          $RecipesTable,
                          CategoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      RecipeRow,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (RecipeRow, $$RecipesTableReferences),
      RecipeRow,
      PrefetchHooks Function({
        bool photoId,
        bool recipeIngredientsRefs,
        bool recipeCategoriesRefs,
      })
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      required int recipeId,
      required int position,
      required String name,
      required double quantity,
      required String unit,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      Value<int> recipeId,
      Value<int> position,
      Value<String> name,
      Value<double> quantity,
      Value<String> unit,
    });

final class $$RecipeIngredientsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RecipeIngredientsTable, IngredientRow> {
  $$RecipeIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_ingredients__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<int>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          IngredientRow,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (IngredientRow, $$RecipeIngredientsTableReferences),
          IngredientRow,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                name: name,
                quantity: quantity,
                unit: unit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recipeId,
                required int position,
                required String name,
                required double quantity,
                required String unit,
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                name: name,
                quantity: quantity,
                unit: unit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable:
                                    $$RecipeIngredientsTableReferences
                                        ._recipeIdTable(db),
                                referencedColumn:
                                    $$RecipeIngredientsTableReferences
                                        ._recipeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      IngredientRow,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (IngredientRow, $$RecipeIngredientsTableReferences),
      IngredientRow,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$RecipeCategoriesTableCreateCompanionBuilder =
    RecipeCategoriesCompanion Function({
      Value<int> id,
      required int recipeId,
      required int position,
      required String name,
    });
typedef $$RecipeCategoriesTableUpdateCompanionBuilder =
    RecipeCategoriesCompanion Function({
      Value<int> id,
      Value<int> recipeId,
      Value<int> position,
      Value<String> name,
    });

final class $$RecipeCategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeCategoriesTable, CategoryRow> {
  $$RecipeCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias('recipe_categories__recipe_id__recipes__id');

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<int>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeCategoriesTable> {
  $$RecipeCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeCategoriesTable> {
  $$RecipeCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeCategoriesTable> {
  $$RecipeCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeCategoriesTable,
          CategoryRow,
          $$RecipeCategoriesTableFilterComposer,
          $$RecipeCategoriesTableOrderingComposer,
          $$RecipeCategoriesTableAnnotationComposer,
          $$RecipeCategoriesTableCreateCompanionBuilder,
          $$RecipeCategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$RecipeCategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeCategoriesTableTableManager(
    _$AppDatabase db,
    $RecipeCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => RecipeCategoriesCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                name: name,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int recipeId,
                required int position,
                required String name,
              }) => RecipeCategoriesCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable:
                                    $$RecipeCategoriesTableReferences
                                        ._recipeIdTable(db),
                                referencedColumn:
                                    $$RecipeCategoriesTableReferences
                                        ._recipeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeCategoriesTable,
      CategoryRow,
      $$RecipeCategoriesTableFilterComposer,
      $$RecipeCategoriesTableOrderingComposer,
      $$RecipeCategoriesTableAnnotationComposer,
      $$RecipeCategoriesTableCreateCompanionBuilder,
      $$RecipeCategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$RecipeCategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$GroceryListsTableCreateCompanionBuilder =
    GroceryListsCompanion Function({
      Value<int> id,
      required String uuid,
      required String weekStart,
    });
typedef $$GroceryListsTableUpdateCompanionBuilder =
    GroceryListsCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> weekStart,
    });

final class $$GroceryListsTableReferences
    extends BaseReferences<_$AppDatabase, $GroceryListsTable, GroceryListRow> {
  $$GroceryListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $GroceryListRecipesTable,
    List<GroceryListRecipeRow>
  >
  _groceryListRecipesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groceryListRecipes,
        aliasName: 'grocery_lists__id__grocery_list_recipes__list_id',
      );

  $$GroceryListRecipesTableProcessedTableManager get groceryListRecipesRefs {
    final manager = $$GroceryListRecipesTableTableManager(
      $_db,
      $_db.groceryListRecipes,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groceryListRecipesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GroceryListItemsTable, List<GroceryListItemRow>>
  _groceryListItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.groceryListItems,
    aliasName: 'grocery_lists__id__grocery_list_items__list_id',
  );

  $$GroceryListItemsTableProcessedTableManager get groceryListItemsRefs {
    final manager = $$GroceryListItemsTableTableManager(
      $_db,
      $_db.groceryListItems,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groceryListItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GroceryListsTableFilterComposer
    extends Composer<_$AppDatabase, $GroceryListsTable> {
  $$GroceryListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groceryListRecipesRefs(
    Expression<bool> Function($$GroceryListRecipesTableFilterComposer f) f,
  ) {
    final $$GroceryListRecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groceryListRecipes,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListRecipesTableFilterComposer(
            $db: $db,
            $table: $db.groceryListRecipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> groceryListItemsRefs(
    Expression<bool> Function($$GroceryListItemsTableFilterComposer f) f,
  ) {
    final $$GroceryListItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groceryListItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListItemsTableFilterComposer(
            $db: $db,
            $table: $db.groceryListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroceryListsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroceryListsTable> {
  $$GroceryListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroceryListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroceryListsTable> {
  $$GroceryListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  Expression<T> groceryListRecipesRefs<T extends Object>(
    Expression<T> Function($$GroceryListRecipesTableAnnotationComposer a) f,
  ) {
    final $$GroceryListRecipesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groceryListRecipes,
          getReferencedColumn: (t) => t.listId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroceryListRecipesTableAnnotationComposer(
                $db: $db,
                $table: $db.groceryListRecipes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> groceryListItemsRefs<T extends Object>(
    Expression<T> Function($$GroceryListItemsTableAnnotationComposer a) f,
  ) {
    final $$GroceryListItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groceryListItems,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.groceryListItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GroceryListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroceryListsTable,
          GroceryListRow,
          $$GroceryListsTableFilterComposer,
          $$GroceryListsTableOrderingComposer,
          $$GroceryListsTableAnnotationComposer,
          $$GroceryListsTableCreateCompanionBuilder,
          $$GroceryListsTableUpdateCompanionBuilder,
          (GroceryListRow, $$GroceryListsTableReferences),
          GroceryListRow,
          PrefetchHooks Function({
            bool groceryListRecipesRefs,
            bool groceryListItemsRefs,
          })
        > {
  $$GroceryListsTableTableManager(_$AppDatabase db, $GroceryListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroceryListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroceryListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroceryListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> weekStart = const Value.absent(),
              }) => GroceryListsCompanion(
                id: id,
                uuid: uuid,
                weekStart: weekStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String weekStart,
              }) => GroceryListsCompanion.insert(
                id: id,
                uuid: uuid,
                weekStart: weekStart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroceryListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({groceryListRecipesRefs = false, groceryListItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (groceryListRecipesRefs) db.groceryListRecipes,
                    if (groceryListItemsRefs) db.groceryListItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (groceryListRecipesRefs)
                        await $_getPrefetchedData<
                          GroceryListRow,
                          $GroceryListsTable,
                          GroceryListRecipeRow
                        >(
                          currentTable: table,
                          referencedTable: $$GroceryListsTableReferences
                              ._groceryListRecipesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroceryListsTableReferences(
                                db,
                                table,
                                p0,
                              ).groceryListRecipesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.listId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (groceryListItemsRefs)
                        await $_getPrefetchedData<
                          GroceryListRow,
                          $GroceryListsTable,
                          GroceryListItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$GroceryListsTableReferences
                              ._groceryListItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GroceryListsTableReferences(
                                db,
                                table,
                                p0,
                              ).groceryListItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.listId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GroceryListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroceryListsTable,
      GroceryListRow,
      $$GroceryListsTableFilterComposer,
      $$GroceryListsTableOrderingComposer,
      $$GroceryListsTableAnnotationComposer,
      $$GroceryListsTableCreateCompanionBuilder,
      $$GroceryListsTableUpdateCompanionBuilder,
      (GroceryListRow, $$GroceryListsTableReferences),
      GroceryListRow,
      PrefetchHooks Function({
        bool groceryListRecipesRefs,
        bool groceryListItemsRefs,
      })
    >;
typedef $$GroceryListRecipesTableCreateCompanionBuilder =
    GroceryListRecipesCompanion Function({
      Value<int> id,
      required int listId,
      required int position,
      required String title,
    });
typedef $$GroceryListRecipesTableUpdateCompanionBuilder =
    GroceryListRecipesCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<int> position,
      Value<String> title,
    });

final class $$GroceryListRecipesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroceryListRecipesTable,
          GroceryListRecipeRow
        > {
  $$GroceryListRecipesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroceryListsTable _listIdTable(_$AppDatabase db) => db.groceryLists
      .createAlias('grocery_list_recipes__list_id__grocery_lists__id');

  $$GroceryListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$GroceryListsTableTableManager(
      $_db,
      $_db.groceryLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroceryListRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $GroceryListRecipesTable> {
  $$GroceryListRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  $$GroceryListsTableFilterComposer get listId {
    final $$GroceryListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.groceryLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListsTableFilterComposer(
            $db: $db,
            $table: $db.groceryLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroceryListRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $GroceryListRecipesTable> {
  $$GroceryListRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroceryListsTableOrderingComposer get listId {
    final $$GroceryListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.groceryLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListsTableOrderingComposer(
            $db: $db,
            $table: $db.groceryLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroceryListRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroceryListRecipesTable> {
  $$GroceryListRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  $$GroceryListsTableAnnotationComposer get listId {
    final $$GroceryListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.groceryLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListsTableAnnotationComposer(
            $db: $db,
            $table: $db.groceryLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroceryListRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroceryListRecipesTable,
          GroceryListRecipeRow,
          $$GroceryListRecipesTableFilterComposer,
          $$GroceryListRecipesTableOrderingComposer,
          $$GroceryListRecipesTableAnnotationComposer,
          $$GroceryListRecipesTableCreateCompanionBuilder,
          $$GroceryListRecipesTableUpdateCompanionBuilder,
          (GroceryListRecipeRow, $$GroceryListRecipesTableReferences),
          GroceryListRecipeRow,
          PrefetchHooks Function({bool listId})
        > {
  $$GroceryListRecipesTableTableManager(
    _$AppDatabase db,
    $GroceryListRecipesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroceryListRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroceryListRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroceryListRecipesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> title = const Value.absent(),
              }) => GroceryListRecipesCompanion(
                id: id,
                listId: listId,
                position: position,
                title: title,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required int position,
                required String title,
              }) => GroceryListRecipesCompanion.insert(
                id: id,
                listId: listId,
                position: position,
                title: title,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroceryListRecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$GroceryListRecipesTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$GroceryListRecipesTableReferences
                                        ._listIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroceryListRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroceryListRecipesTable,
      GroceryListRecipeRow,
      $$GroceryListRecipesTableFilterComposer,
      $$GroceryListRecipesTableOrderingComposer,
      $$GroceryListRecipesTableAnnotationComposer,
      $$GroceryListRecipesTableCreateCompanionBuilder,
      $$GroceryListRecipesTableUpdateCompanionBuilder,
      (GroceryListRecipeRow, $$GroceryListRecipesTableReferences),
      GroceryListRecipeRow,
      PrefetchHooks Function({bool listId})
    >;
typedef $$GroceryListItemsTableCreateCompanionBuilder =
    GroceryListItemsCompanion Function({
      Value<int> id,
      required int listId,
      required int position,
      required String name,
      required double quantity,
      required String unit,
      Value<bool> ticked,
    });
typedef $$GroceryListItemsTableUpdateCompanionBuilder =
    GroceryListItemsCompanion Function({
      Value<int> id,
      Value<int> listId,
      Value<int> position,
      Value<String> name,
      Value<double> quantity,
      Value<String> unit,
      Value<bool> ticked,
    });

final class $$GroceryListItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroceryListItemsTable,
          GroceryListItemRow
        > {
  $$GroceryListItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GroceryListsTable _listIdTable(_$AppDatabase db) => db.groceryLists
      .createAlias('grocery_list_items__list_id__grocery_lists__id');

  $$GroceryListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$GroceryListsTableTableManager(
      $_db,
      $_db.groceryLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroceryListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $GroceryListItemsTable> {
  $$GroceryListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ticked => $composableBuilder(
    column: $table.ticked,
    builder: (column) => ColumnFilters(column),
  );

  $$GroceryListsTableFilterComposer get listId {
    final $$GroceryListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.groceryLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListsTableFilterComposer(
            $db: $db,
            $table: $db.groceryLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroceryListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroceryListItemsTable> {
  $$GroceryListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ticked => $composableBuilder(
    column: $table.ticked,
    builder: (column) => ColumnOrderings(column),
  );

  $$GroceryListsTableOrderingComposer get listId {
    final $$GroceryListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.groceryLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListsTableOrderingComposer(
            $db: $db,
            $table: $db.groceryLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroceryListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroceryListItemsTable> {
  $$GroceryListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get ticked =>
      $composableBuilder(column: $table.ticked, builder: (column) => column);

  $$GroceryListsTableAnnotationComposer get listId {
    final $$GroceryListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.groceryLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryListsTableAnnotationComposer(
            $db: $db,
            $table: $db.groceryLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroceryListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroceryListItemsTable,
          GroceryListItemRow,
          $$GroceryListItemsTableFilterComposer,
          $$GroceryListItemsTableOrderingComposer,
          $$GroceryListItemsTableAnnotationComposer,
          $$GroceryListItemsTableCreateCompanionBuilder,
          $$GroceryListItemsTableUpdateCompanionBuilder,
          (GroceryListItemRow, $$GroceryListItemsTableReferences),
          GroceryListItemRow,
          PrefetchHooks Function({bool listId})
        > {
  $$GroceryListItemsTableTableManager(
    _$AppDatabase db,
    $GroceryListItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroceryListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroceryListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroceryListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> listId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<bool> ticked = const Value.absent(),
              }) => GroceryListItemsCompanion(
                id: id,
                listId: listId,
                position: position,
                name: name,
                quantity: quantity,
                unit: unit,
                ticked: ticked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int listId,
                required int position,
                required String name,
                required double quantity,
                required String unit,
                Value<bool> ticked = const Value.absent(),
              }) => GroceryListItemsCompanion.insert(
                id: id,
                listId: listId,
                position: position,
                name: name,
                quantity: quantity,
                unit: unit,
                ticked: ticked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroceryListItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$GroceryListItemsTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$GroceryListItemsTableReferences
                                        ._listIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroceryListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroceryListItemsTable,
      GroceryListItemRow,
      $$GroceryListItemsTableFilterComposer,
      $$GroceryListItemsTableOrderingComposer,
      $$GroceryListItemsTableAnnotationComposer,
      $$GroceryListItemsTableCreateCompanionBuilder,
      $$GroceryListItemsTableUpdateCompanionBuilder,
      (GroceryListItemRow, $$GroceryListItemsTableReferences),
      GroceryListItemRow,
      PrefetchHooks Function({bool listId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$RecipeCategoriesTableTableManager get recipeCategories =>
      $$RecipeCategoriesTableTableManager(_db, _db.recipeCategories);
  $$GroceryListsTableTableManager get groceryLists =>
      $$GroceryListsTableTableManager(_db, _db.groceryLists);
  $$GroceryListRecipesTableTableManager get groceryListRecipes =>
      $$GroceryListRecipesTableTableManager(_db, _db.groceryListRecipes);
  $$GroceryListItemsTableTableManager get groceryListItems =>
      $$GroceryListItemsTableTableManager(_db, _db.groceryListItems);
}
