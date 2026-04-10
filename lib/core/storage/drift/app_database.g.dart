// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RegistrosLocalTable extends RegistrosLocal
    with TableInfo<$RegistrosLocalTable, RegistrosLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plantillaIdMeta = const VerificationMeta(
    'plantillaId',
  );
  @override
  late final GeneratedColumn<int> plantillaId = GeneratedColumn<int>(
    'plantilla_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateKeyMeta = const VerificationMeta(
    'templateKey',
  );
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
    'template_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaniaIdMeta = const VerificationMeta(
    'campaniaId',
  );
  @override
  late final GeneratedColumn<String> campaniaId = GeneratedColumn<String>(
    'campania_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteIdMeta = const VerificationMeta('loteId');
  @override
  late final GeneratedColumn<int> loteId = GeneratedColumn<int>(
    'lote_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('borrador'),
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
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _syncErrorMeta = const VerificationMeta(
    'syncError',
  );
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
    'sync_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncAttemptsMeta = const VerificationMeta(
    'syncAttempts',
  );
  @override
  late final GeneratedColumn<int> syncAttempts = GeneratedColumn<int>(
    'sync_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    plantillaId,
    templateKey,
    userId,
    campaniaId,
    loteId,
    lat,
    lon,
    estado,
    syncStatus,
    syncError,
    syncAttempts,
    dataJson,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistrosLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('plantilla_id')) {
      context.handle(
        _plantillaIdMeta,
        plantillaId.isAcceptableOrUnknown(
          data['plantilla_id']!,
          _plantillaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plantillaIdMeta);
    }
    if (data.containsKey('template_key')) {
      context.handle(
        _templateKeyMeta,
        templateKey.isAcceptableOrUnknown(
          data['template_key']!,
          _templateKeyMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('campania_id')) {
      context.handle(
        _campaniaIdMeta,
        campaniaId.isAcceptableOrUnknown(data['campania_id']!, _campaniaIdMeta),
      );
    }
    if (data.containsKey('lote_id')) {
      context.handle(
        _loteIdMeta,
        loteId.isAcceptableOrUnknown(data['lote_id']!, _loteIdMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('sync_error')) {
      context.handle(
        _syncErrorMeta,
        syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta),
      );
    }
    if (data.containsKey('sync_attempts')) {
      context.handle(
        _syncAttemptsMeta,
        syncAttempts.isAcceptableOrUnknown(
          data['sync_attempts']!,
          _syncAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  RegistrosLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistrosLocalData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      plantillaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plantilla_id'],
      )!,
      templateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_key'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      campaniaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campania_id'],
      ),
      loteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lote_id'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      syncError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_error'],
      ),
      syncAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_attempts'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RegistrosLocalTable createAlias(String alias) {
    return $RegistrosLocalTable(attachedDatabase, alias);
  }
}

class RegistrosLocalData extends DataClass
    implements Insertable<RegistrosLocalData> {
  final int localId;
  final int? serverId;
  final int plantillaId;
  final String templateKey;
  final int userId;
  final String? campaniaId;
  final int? loteId;
  final double? lat;
  final double? lon;
  final String estado;
  final String syncStatus;
  final String? syncError;
  final int syncAttempts;
  final String dataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const RegistrosLocalData({
    required this.localId,
    this.serverId,
    required this.plantillaId,
    required this.templateKey,
    required this.userId,
    this.campaniaId,
    this.loteId,
    this.lat,
    this.lon,
    required this.estado,
    required this.syncStatus,
    this.syncError,
    required this.syncAttempts,
    required this.dataJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['plantilla_id'] = Variable<int>(plantillaId);
    map['template_key'] = Variable<String>(templateKey);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || campaniaId != null) {
      map['campania_id'] = Variable<String>(campaniaId);
    }
    if (!nullToAbsent || loteId != null) {
      map['lote_id'] = Variable<int>(loteId);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lon != null) {
      map['lon'] = Variable<double>(lon);
    }
    map['estado'] = Variable<String>(estado);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    map['sync_attempts'] = Variable<int>(syncAttempts);
    map['data_json'] = Variable<String>(dataJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RegistrosLocalCompanion toCompanion(bool nullToAbsent) {
    return RegistrosLocalCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      plantillaId: Value(plantillaId),
      templateKey: Value(templateKey),
      userId: Value(userId),
      campaniaId: campaniaId == null && nullToAbsent
          ? const Value.absent()
          : Value(campaniaId),
      loteId: loteId == null && nullToAbsent
          ? const Value.absent()
          : Value(loteId),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lon: lon == null && nullToAbsent ? const Value.absent() : Value(lon),
      estado: Value(estado),
      syncStatus: Value(syncStatus),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
      syncAttempts: Value(syncAttempts),
      dataJson: Value(dataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RegistrosLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistrosLocalData(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      plantillaId: serializer.fromJson<int>(json['plantillaId']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      userId: serializer.fromJson<int>(json['userId']),
      campaniaId: serializer.fromJson<String?>(json['campaniaId']),
      loteId: serializer.fromJson<int?>(json['loteId']),
      lat: serializer.fromJson<double?>(json['lat']),
      lon: serializer.fromJson<double?>(json['lon']),
      estado: serializer.fromJson<String>(json['estado']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncError: serializer.fromJson<String?>(json['syncError']),
      syncAttempts: serializer.fromJson<int>(json['syncAttempts']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'plantillaId': serializer.toJson<int>(plantillaId),
      'templateKey': serializer.toJson<String>(templateKey),
      'userId': serializer.toJson<int>(userId),
      'campaniaId': serializer.toJson<String?>(campaniaId),
      'loteId': serializer.toJson<int?>(loteId),
      'lat': serializer.toJson<double?>(lat),
      'lon': serializer.toJson<double?>(lon),
      'estado': serializer.toJson<String>(estado),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncError': serializer.toJson<String?>(syncError),
      'syncAttempts': serializer.toJson<int>(syncAttempts),
      'dataJson': serializer.toJson<String>(dataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RegistrosLocalData copyWith({
    int? localId,
    Value<int?> serverId = const Value.absent(),
    int? plantillaId,
    String? templateKey,
    int? userId,
    Value<String?> campaniaId = const Value.absent(),
    Value<int?> loteId = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lon = const Value.absent(),
    String? estado,
    String? syncStatus,
    Value<String?> syncError = const Value.absent(),
    int? syncAttempts,
    String? dataJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => RegistrosLocalData(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    plantillaId: plantillaId ?? this.plantillaId,
    templateKey: templateKey ?? this.templateKey,
    userId: userId ?? this.userId,
    campaniaId: campaniaId.present ? campaniaId.value : this.campaniaId,
    loteId: loteId.present ? loteId.value : this.loteId,
    lat: lat.present ? lat.value : this.lat,
    lon: lon.present ? lon.value : this.lon,
    estado: estado ?? this.estado,
    syncStatus: syncStatus ?? this.syncStatus,
    syncError: syncError.present ? syncError.value : this.syncError,
    syncAttempts: syncAttempts ?? this.syncAttempts,
    dataJson: dataJson ?? this.dataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RegistrosLocalData copyWithCompanion(RegistrosLocalCompanion data) {
    return RegistrosLocalData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      plantillaId: data.plantillaId.present
          ? data.plantillaId.value
          : this.plantillaId,
      templateKey: data.templateKey.present
          ? data.templateKey.value
          : this.templateKey,
      userId: data.userId.present ? data.userId.value : this.userId,
      campaniaId: data.campaniaId.present
          ? data.campaniaId.value
          : this.campaniaId,
      loteId: data.loteId.present ? data.loteId.value : this.loteId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      estado: data.estado.present ? data.estado.value : this.estado,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
      syncAttempts: data.syncAttempts.present
          ? data.syncAttempts.value
          : this.syncAttempts,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosLocalData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('plantillaId: $plantillaId, ')
          ..write('templateKey: $templateKey, ')
          ..write('userId: $userId, ')
          ..write('campaniaId: $campaniaId, ')
          ..write('loteId: $loteId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('estado: $estado, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('syncAttempts: $syncAttempts, ')
          ..write('dataJson: $dataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    plantillaId,
    templateKey,
    userId,
    campaniaId,
    loteId,
    lat,
    lon,
    estado,
    syncStatus,
    syncError,
    syncAttempts,
    dataJson,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistrosLocalData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.plantillaId == this.plantillaId &&
          other.templateKey == this.templateKey &&
          other.userId == this.userId &&
          other.campaniaId == this.campaniaId &&
          other.loteId == this.loteId &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.estado == this.estado &&
          other.syncStatus == this.syncStatus &&
          other.syncError == this.syncError &&
          other.syncAttempts == this.syncAttempts &&
          other.dataJson == this.dataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RegistrosLocalCompanion extends UpdateCompanion<RegistrosLocalData> {
  final Value<int> localId;
  final Value<int?> serverId;
  final Value<int> plantillaId;
  final Value<String> templateKey;
  final Value<int> userId;
  final Value<String?> campaniaId;
  final Value<int?> loteId;
  final Value<double?> lat;
  final Value<double?> lon;
  final Value<String> estado;
  final Value<String> syncStatus;
  final Value<String?> syncError;
  final Value<int> syncAttempts;
  final Value<String> dataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const RegistrosLocalCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.plantillaId = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.userId = const Value.absent(),
    this.campaniaId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.estado = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncAttempts = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  RegistrosLocalCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    required int plantillaId,
    this.templateKey = const Value.absent(),
    required int userId,
    this.campaniaId = const Value.absent(),
    this.loteId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.estado = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncError = const Value.absent(),
    this.syncAttempts = const Value.absent(),
    this.dataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : plantillaId = Value(plantillaId),
       userId = Value(userId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RegistrosLocalData> custom({
    Expression<int>? localId,
    Expression<int>? serverId,
    Expression<int>? plantillaId,
    Expression<String>? templateKey,
    Expression<int>? userId,
    Expression<String>? campaniaId,
    Expression<int>? loteId,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? estado,
    Expression<String>? syncStatus,
    Expression<String>? syncError,
    Expression<int>? syncAttempts,
    Expression<String>? dataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (plantillaId != null) 'plantilla_id': plantillaId,
      if (templateKey != null) 'template_key': templateKey,
      if (userId != null) 'user_id': userId,
      if (campaniaId != null) 'campania_id': campaniaId,
      if (loteId != null) 'lote_id': loteId,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (estado != null) 'estado': estado,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncError != null) 'sync_error': syncError,
      if (syncAttempts != null) 'sync_attempts': syncAttempts,
      if (dataJson != null) 'data_json': dataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  RegistrosLocalCompanion copyWith({
    Value<int>? localId,
    Value<int?>? serverId,
    Value<int>? plantillaId,
    Value<String>? templateKey,
    Value<int>? userId,
    Value<String?>? campaniaId,
    Value<int?>? loteId,
    Value<double?>? lat,
    Value<double?>? lon,
    Value<String>? estado,
    Value<String>? syncStatus,
    Value<String?>? syncError,
    Value<int>? syncAttempts,
    Value<String>? dataJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return RegistrosLocalCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      plantillaId: plantillaId ?? this.plantillaId,
      templateKey: templateKey ?? this.templateKey,
      userId: userId ?? this.userId,
      campaniaId: campaniaId ?? this.campaniaId,
      loteId: loteId ?? this.loteId,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      estado: estado ?? this.estado,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      dataJson: dataJson ?? this.dataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (plantillaId.present) {
      map['plantilla_id'] = Variable<int>(plantillaId.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (campaniaId.present) {
      map['campania_id'] = Variable<String>(campaniaId.value);
    }
    if (loteId.present) {
      map['lote_id'] = Variable<int>(loteId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (syncAttempts.present) {
      map['sync_attempts'] = Variable<int>(syncAttempts.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosLocalCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('plantillaId: $plantillaId, ')
          ..write('templateKey: $templateKey, ')
          ..write('userId: $userId, ')
          ..write('campaniaId: $campaniaId, ')
          ..write('loteId: $loteId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('estado: $estado, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncError: $syncError, ')
          ..write('syncAttempts: $syncAttempts, ')
          ..write('dataJson: $dataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PlantillasLocalTable extends PlantillasLocal
    with TableInfo<$PlantillasLocalTable, PlantillasLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlantillasLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _plantillaIdMeta = const VerificationMeta(
    'plantillaId',
  );
  @override
  late final GeneratedColumn<int> plantillaId = GeneratedColumn<int>(
    'plantilla_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    plantillaId,
    userId,
    codigo,
    nombre,
    descripcion,
    version,
    isActive,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plantillas_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlantillasLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plantilla_id')) {
      context.handle(
        _plantillaIdMeta,
        plantillaId.isAcceptableOrUnknown(
          data['plantilla_id']!,
          _plantillaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plantillaIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {plantillaId, userId};
  @override
  PlantillasLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlantillasLocalData(
      plantillaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plantilla_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      ),
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PlantillasLocalTable createAlias(String alias) {
    return $PlantillasLocalTable(attachedDatabase, alias);
  }
}

class PlantillasLocalData extends DataClass
    implements Insertable<PlantillasLocalData> {
  final int plantillaId;
  final int userId;
  final String? codigo;
  final String? nombre;
  final String? descripcion;
  final int version;
  final bool isActive;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const PlantillasLocalData({
    required this.plantillaId,
    required this.userId,
    this.codigo,
    this.nombre,
    this.descripcion,
    required this.version,
    required this.isActive,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plantilla_id'] = Variable<int>(plantillaId);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || codigo != null) {
      map['codigo'] = Variable<String>(codigo);
    }
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['version'] = Variable<int>(version);
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PlantillasLocalCompanion toCompanion(bool nullToAbsent) {
    return PlantillasLocalCompanion(
      plantillaId: Value(plantillaId),
      userId: Value(userId),
      codigo: codigo == null && nullToAbsent
          ? const Value.absent()
          : Value(codigo),
      nombre: nombre == null && nullToAbsent
          ? const Value.absent()
          : Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      version: Value(version),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PlantillasLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlantillasLocalData(
      plantillaId: serializer.fromJson<int>(json['plantillaId']),
      userId: serializer.fromJson<int>(json['userId']),
      codigo: serializer.fromJson<String?>(json['codigo']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      version: serializer.fromJson<int>(json['version']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'plantillaId': serializer.toJson<int>(plantillaId),
      'userId': serializer.toJson<int>(userId),
      'codigo': serializer.toJson<String?>(codigo),
      'nombre': serializer.toJson<String?>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'version': serializer.toJson<int>(version),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PlantillasLocalData copyWith({
    int? plantillaId,
    int? userId,
    Value<String?> codigo = const Value.absent(),
    Value<String?> nombre = const Value.absent(),
    Value<String?> descripcion = const Value.absent(),
    int? version,
    bool? isActive,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PlantillasLocalData(
    plantillaId: plantillaId ?? this.plantillaId,
    userId: userId ?? this.userId,
    codigo: codigo.present ? codigo.value : this.codigo,
    nombre: nombre.present ? nombre.value : this.nombre,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    version: version ?? this.version,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PlantillasLocalData copyWithCompanion(PlantillasLocalCompanion data) {
    return PlantillasLocalData(
      plantillaId: data.plantillaId.present
          ? data.plantillaId.value
          : this.plantillaId,
      userId: data.userId.present ? data.userId.value : this.userId,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      version: data.version.present ? data.version.value : this.version,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlantillasLocalData(')
          ..write('plantillaId: $plantillaId, ')
          ..write('userId: $userId, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    plantillaId,
    userId,
    codigo,
    nombre,
    descripcion,
    version,
    isActive,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlantillasLocalData &&
          other.plantillaId == this.plantillaId &&
          other.userId == this.userId &&
          other.codigo == this.codigo &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.version == this.version &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PlantillasLocalCompanion extends UpdateCompanion<PlantillasLocalData> {
  final Value<int> plantillaId;
  final Value<int> userId;
  final Value<String?> codigo;
  final Value<String?> nombre;
  final Value<String?> descripcion;
  final Value<int> version;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PlantillasLocalCompanion({
    this.plantillaId = const Value.absent(),
    this.userId = const Value.absent(),
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlantillasLocalCompanion.insert({
    required int plantillaId,
    required int userId,
    this.codigo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.version = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : plantillaId = Value(plantillaId),
       userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<PlantillasLocalData> custom({
    Expression<int>? plantillaId,
    Expression<int>? userId,
    Expression<String>? codigo,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<int>? version,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (plantillaId != null) 'plantilla_id': plantillaId,
      if (userId != null) 'user_id': userId,
      if (codigo != null) 'codigo': codigo,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (version != null) 'version': version,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlantillasLocalCompanion copyWith({
    Value<int>? plantillaId,
    Value<int>? userId,
    Value<String?>? codigo,
    Value<String?>? nombre,
    Value<String?>? descripcion,
    Value<int>? version,
    Value<bool>? isActive,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PlantillasLocalCompanion(
      plantillaId: plantillaId ?? this.plantillaId,
      userId: userId ?? this.userId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (plantillaId.present) {
      map['plantilla_id'] = Variable<int>(plantillaId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlantillasLocalCompanion(')
          ..write('plantillaId: $plantillaId, ')
          ..write('userId: $userId, ')
          ..write('codigo: $codigo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('version: $version, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorLocalTable extends SyncCursorLocal
    with TableInfo<$SyncCursorLocalTable, SyncCursorLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<DateTime> value = GeneratedColumn<DateTime>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursor_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncCursorLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorLocalData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncCursorLocalTable createAlias(String alias) {
    return $SyncCursorLocalTable(attachedDatabase, alias);
  }
}

class SyncCursorLocalData extends DataClass
    implements Insertable<SyncCursorLocalData> {
  final String key;
  final DateTime value;
  const SyncCursorLocalData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<DateTime>(value);
    return map;
  }

  SyncCursorLocalCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorLocalCompanion(key: Value(key), value: Value(value));
  }

  factory SyncCursorLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorLocalData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<DateTime>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<DateTime>(value),
    };
  }

  SyncCursorLocalData copyWith({String? key, DateTime? value}) =>
      SyncCursorLocalData(key: key ?? this.key, value: value ?? this.value);
  SyncCursorLocalData copyWithCompanion(SyncCursorLocalCompanion data) {
    return SyncCursorLocalData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorLocalData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorLocalData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncCursorLocalCompanion extends UpdateCompanion<SyncCursorLocalData> {
  final Value<String> key;
  final Value<DateTime> value;
  final Value<int> rowid;
  const SyncCursorLocalCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorLocalCompanion.insert({
    required String key,
    required DateTime value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncCursorLocalData> custom({
    Expression<String>? key,
    Expression<DateTime>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorLocalCompanion copyWith({
    Value<String>? key,
    Value<DateTime>? value,
    Value<int>? rowid,
  }) {
    return SyncCursorLocalCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<DateTime>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorLocalCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaniasTableTable extends CampaniasTable
    with TableInfo<$CampaniasTableTable, CampaniasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaniasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idCampaniaMeta = const VerificationMeta(
    'idCampania',
  );
  @override
  late final GeneratedColumn<String> idCampania = GeneratedColumn<String>(
    'id_campania',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [idCampania, descripcion, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campanias_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CampaniasTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_campania')) {
      context.handle(
        _idCampaniaMeta,
        idCampania.isAcceptableOrUnknown(data['id_campania']!, _idCampaniaMeta),
      );
    } else if (isInserting) {
      context.missing(_idCampaniaMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idCampania};
  @override
  CampaniasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaniasTableData(
      idCampania: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_campania'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CampaniasTableTable createAlias(String alias) {
    return $CampaniasTableTable(attachedDatabase, alias);
  }
}

class CampaniasTableData extends DataClass
    implements Insertable<CampaniasTableData> {
  final String idCampania;
  final String descripcion;
  final int? updatedAt;
  const CampaniasTableData({
    required this.idCampania,
    required this.descripcion,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_campania'] = Variable<String>(idCampania);
    map['descripcion'] = Variable<String>(descripcion);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  CampaniasTableCompanion toCompanion(bool nullToAbsent) {
    return CampaniasTableCompanion(
      idCampania: Value(idCampania),
      descripcion: Value(descripcion),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CampaniasTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaniasTableData(
      idCampania: serializer.fromJson<String>(json['idCampania']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idCampania': serializer.toJson<String>(idCampania),
      'descripcion': serializer.toJson<String>(descripcion),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  CampaniasTableData copyWith({
    String? idCampania,
    String? descripcion,
    Value<int?> updatedAt = const Value.absent(),
  }) => CampaniasTableData(
    idCampania: idCampania ?? this.idCampania,
    descripcion: descripcion ?? this.descripcion,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CampaniasTableData copyWithCompanion(CampaniasTableCompanion data) {
    return CampaniasTableData(
      idCampania: data.idCampania.present
          ? data.idCampania.value
          : this.idCampania,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaniasTableData(')
          ..write('idCampania: $idCampania, ')
          ..write('descripcion: $descripcion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idCampania, descripcion, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaniasTableData &&
          other.idCampania == this.idCampania &&
          other.descripcion == this.descripcion &&
          other.updatedAt == this.updatedAt);
}

class CampaniasTableCompanion extends UpdateCompanion<CampaniasTableData> {
  final Value<String> idCampania;
  final Value<String> descripcion;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const CampaniasTableCompanion({
    this.idCampania = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaniasTableCompanion.insert({
    required String idCampania,
    required String descripcion,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : idCampania = Value(idCampania),
       descripcion = Value(descripcion);
  static Insertable<CampaniasTableData> custom({
    Expression<String>? idCampania,
    Expression<String>? descripcion,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idCampania != null) 'id_campania': idCampania,
      if (descripcion != null) 'descripcion': descripcion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaniasTableCompanion copyWith({
    Value<String>? idCampania,
    Value<String>? descripcion,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CampaniasTableCompanion(
      idCampania: idCampania ?? this.idCampania,
      descripcion: descripcion ?? this.descripcion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idCampania.present) {
      map['id_campania'] = Variable<String>(idCampania.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaniasTableCompanion(')
          ..write('idCampania: $idCampania, ')
          ..write('descripcion: $descripcion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotesTableTable extends LotesTable
    with TableInfo<$LotesTableTable, LotesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idLoteMeta = const VerificationMeta('idLote');
  @override
  late final GeneratedColumn<int> idLote = GeneratedColumn<int>(
    'id_lote',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoLoteMeta = const VerificationMeta(
    'codigoLote',
  );
  @override
  late final GeneratedColumn<String> codigoLote = GeneratedColumn<String>(
    'codigo_lote',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loteMeta = const VerificationMeta('lote');
  @override
  late final GeneratedColumn<String> lote = GeneratedColumn<String>(
    'lote',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subLoteMeta = const VerificationMeta(
    'subLote',
  );
  @override
  late final GeneratedColumn<String> subLote = GeneratedColumn<String>(
    'sub_lote',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cultivoMeta = const VerificationMeta(
    'cultivo',
  );
  @override
  late final GeneratedColumn<String> cultivo = GeneratedColumn<String>(
    'cultivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<bool> estado = GeneratedColumn<bool>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("estado" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _areaTotalMeta = const VerificationMeta(
    'areaTotal',
  );
  @override
  late final GeneratedColumn<double> areaTotal = GeneratedColumn<double>(
    'area_total',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idFundoMeta = const VerificationMeta(
    'idFundo',
  );
  @override
  late final GeneratedColumn<String> idFundo = GeneratedColumn<String>(
    'id_fundo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idVariedadMeta = const VerificationMeta(
    'idVariedad',
  );
  @override
  late final GeneratedColumn<int> idVariedad = GeneratedColumn<int>(
    'id_variedad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cecoMeta = const VerificationMeta('ceco');
  @override
  late final GeneratedColumn<String> ceco = GeneratedColumn<String>(
    'ceco',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _geomWktMeta = const VerificationMeta(
    'geomWkt',
  );
  @override
  late final GeneratedColumn<String> geomWkt = GeneratedColumn<String>(
    'geom_wkt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minLatMeta = const VerificationMeta('minLat');
  @override
  late final GeneratedColumn<double> minLat = GeneratedColumn<double>(
    'min_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minLonMeta = const VerificationMeta('minLon');
  @override
  late final GeneratedColumn<double> minLon = GeneratedColumn<double>(
    'min_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxLatMeta = const VerificationMeta('maxLat');
  @override
  late final GeneratedColumn<double> maxLat = GeneratedColumn<double>(
    'max_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxLonMeta = const VerificationMeta('maxLon');
  @override
  late final GeneratedColumn<double> maxLon = GeneratedColumn<double>(
    'max_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idLote,
    descripcion,
    codigoLote,
    lote,
    subLote,
    cultivo,
    estado,
    areaTotal,
    idFundo,
    idVariedad,
    ceco,
    geomWkt,
    minLat,
    minLon,
    maxLat,
    maxLon,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lotes_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LotesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_lote')) {
      context.handle(
        _idLoteMeta,
        idLote.isAcceptableOrUnknown(data['id_lote']!, _idLoteMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('codigo_lote')) {
      context.handle(
        _codigoLoteMeta,
        codigoLote.isAcceptableOrUnknown(data['codigo_lote']!, _codigoLoteMeta),
      );
    }
    if (data.containsKey('lote')) {
      context.handle(
        _loteMeta,
        lote.isAcceptableOrUnknown(data['lote']!, _loteMeta),
      );
    }
    if (data.containsKey('sub_lote')) {
      context.handle(
        _subLoteMeta,
        subLote.isAcceptableOrUnknown(data['sub_lote']!, _subLoteMeta),
      );
    }
    if (data.containsKey('cultivo')) {
      context.handle(
        _cultivoMeta,
        cultivo.isAcceptableOrUnknown(data['cultivo']!, _cultivoMeta),
      );
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('area_total')) {
      context.handle(
        _areaTotalMeta,
        areaTotal.isAcceptableOrUnknown(data['area_total']!, _areaTotalMeta),
      );
    }
    if (data.containsKey('id_fundo')) {
      context.handle(
        _idFundoMeta,
        idFundo.isAcceptableOrUnknown(data['id_fundo']!, _idFundoMeta),
      );
    } else if (isInserting) {
      context.missing(_idFundoMeta);
    }
    if (data.containsKey('id_variedad')) {
      context.handle(
        _idVariedadMeta,
        idVariedad.isAcceptableOrUnknown(data['id_variedad']!, _idVariedadMeta),
      );
    } else if (isInserting) {
      context.missing(_idVariedadMeta);
    }
    if (data.containsKey('ceco')) {
      context.handle(
        _cecoMeta,
        ceco.isAcceptableOrUnknown(data['ceco']!, _cecoMeta),
      );
    } else if (isInserting) {
      context.missing(_cecoMeta);
    }
    if (data.containsKey('geom_wkt')) {
      context.handle(
        _geomWktMeta,
        geomWkt.isAcceptableOrUnknown(data['geom_wkt']!, _geomWktMeta),
      );
    }
    if (data.containsKey('min_lat')) {
      context.handle(
        _minLatMeta,
        minLat.isAcceptableOrUnknown(data['min_lat']!, _minLatMeta),
      );
    }
    if (data.containsKey('min_lon')) {
      context.handle(
        _minLonMeta,
        minLon.isAcceptableOrUnknown(data['min_lon']!, _minLonMeta),
      );
    }
    if (data.containsKey('max_lat')) {
      context.handle(
        _maxLatMeta,
        maxLat.isAcceptableOrUnknown(data['max_lat']!, _maxLatMeta),
      );
    }
    if (data.containsKey('max_lon')) {
      context.handle(
        _maxLonMeta,
        maxLon.isAcceptableOrUnknown(data['max_lon']!, _maxLonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idLote};
  @override
  LotesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LotesTableData(
      idLote: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_lote'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      codigoLote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_lote'],
      ),
      lote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lote'],
      ),
      subLote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_lote'],
      ),
      cultivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cultivo'],
      ),
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}estado'],
      )!,
      areaTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_total'],
      ),
      idFundo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_fundo'],
      )!,
      idVariedad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_variedad'],
      )!,
      ceco: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ceco'],
      )!,
      geomWkt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geom_wkt'],
      ),
      minLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_lat'],
      ),
      minLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_lon'],
      ),
      maxLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_lat'],
      ),
      maxLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_lon'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $LotesTableTable createAlias(String alias) {
    return $LotesTableTable(attachedDatabase, alias);
  }
}

class LotesTableData extends DataClass implements Insertable<LotesTableData> {
  final int idLote;
  final String descripcion;
  final String? codigoLote;
  final String? lote;
  final String? subLote;
  final String? cultivo;
  final bool estado;
  final double? areaTotal;
  final String idFundo;
  final int idVariedad;
  final String ceco;
  final String? geomWkt;

  /// Bounding box del polígono (en grados, SRID 4326).
  /// Se usa para filtrar candidatos antes de hacer punto-en-polígono.
  final double? minLat;
  final double? minLon;
  final double? maxLat;
  final double? maxLon;
  final int? updatedAt;
  const LotesTableData({
    required this.idLote,
    required this.descripcion,
    this.codigoLote,
    this.lote,
    this.subLote,
    this.cultivo,
    required this.estado,
    this.areaTotal,
    required this.idFundo,
    required this.idVariedad,
    required this.ceco,
    this.geomWkt,
    this.minLat,
    this.minLon,
    this.maxLat,
    this.maxLon,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_lote'] = Variable<int>(idLote);
    map['descripcion'] = Variable<String>(descripcion);
    if (!nullToAbsent || codigoLote != null) {
      map['codigo_lote'] = Variable<String>(codigoLote);
    }
    if (!nullToAbsent || lote != null) {
      map['lote'] = Variable<String>(lote);
    }
    if (!nullToAbsent || subLote != null) {
      map['sub_lote'] = Variable<String>(subLote);
    }
    if (!nullToAbsent || cultivo != null) {
      map['cultivo'] = Variable<String>(cultivo);
    }
    map['estado'] = Variable<bool>(estado);
    if (!nullToAbsent || areaTotal != null) {
      map['area_total'] = Variable<double>(areaTotal);
    }
    map['id_fundo'] = Variable<String>(idFundo);
    map['id_variedad'] = Variable<int>(idVariedad);
    map['ceco'] = Variable<String>(ceco);
    if (!nullToAbsent || geomWkt != null) {
      map['geom_wkt'] = Variable<String>(geomWkt);
    }
    if (!nullToAbsent || minLat != null) {
      map['min_lat'] = Variable<double>(minLat);
    }
    if (!nullToAbsent || minLon != null) {
      map['min_lon'] = Variable<double>(minLon);
    }
    if (!nullToAbsent || maxLat != null) {
      map['max_lat'] = Variable<double>(maxLat);
    }
    if (!nullToAbsent || maxLon != null) {
      map['max_lon'] = Variable<double>(maxLon);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  LotesTableCompanion toCompanion(bool nullToAbsent) {
    return LotesTableCompanion(
      idLote: Value(idLote),
      descripcion: Value(descripcion),
      codigoLote: codigoLote == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoLote),
      lote: lote == null && nullToAbsent ? const Value.absent() : Value(lote),
      subLote: subLote == null && nullToAbsent
          ? const Value.absent()
          : Value(subLote),
      cultivo: cultivo == null && nullToAbsent
          ? const Value.absent()
          : Value(cultivo),
      estado: Value(estado),
      areaTotal: areaTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(areaTotal),
      idFundo: Value(idFundo),
      idVariedad: Value(idVariedad),
      ceco: Value(ceco),
      geomWkt: geomWkt == null && nullToAbsent
          ? const Value.absent()
          : Value(geomWkt),
      minLat: minLat == null && nullToAbsent
          ? const Value.absent()
          : Value(minLat),
      minLon: minLon == null && nullToAbsent
          ? const Value.absent()
          : Value(minLon),
      maxLat: maxLat == null && nullToAbsent
          ? const Value.absent()
          : Value(maxLat),
      maxLon: maxLon == null && nullToAbsent
          ? const Value.absent()
          : Value(maxLon),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory LotesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LotesTableData(
      idLote: serializer.fromJson<int>(json['idLote']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      codigoLote: serializer.fromJson<String?>(json['codigoLote']),
      lote: serializer.fromJson<String?>(json['lote']),
      subLote: serializer.fromJson<String?>(json['subLote']),
      cultivo: serializer.fromJson<String?>(json['cultivo']),
      estado: serializer.fromJson<bool>(json['estado']),
      areaTotal: serializer.fromJson<double?>(json['areaTotal']),
      idFundo: serializer.fromJson<String>(json['idFundo']),
      idVariedad: serializer.fromJson<int>(json['idVariedad']),
      ceco: serializer.fromJson<String>(json['ceco']),
      geomWkt: serializer.fromJson<String?>(json['geomWkt']),
      minLat: serializer.fromJson<double?>(json['minLat']),
      minLon: serializer.fromJson<double?>(json['minLon']),
      maxLat: serializer.fromJson<double?>(json['maxLat']),
      maxLon: serializer.fromJson<double?>(json['maxLon']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idLote': serializer.toJson<int>(idLote),
      'descripcion': serializer.toJson<String>(descripcion),
      'codigoLote': serializer.toJson<String?>(codigoLote),
      'lote': serializer.toJson<String?>(lote),
      'subLote': serializer.toJson<String?>(subLote),
      'cultivo': serializer.toJson<String?>(cultivo),
      'estado': serializer.toJson<bool>(estado),
      'areaTotal': serializer.toJson<double?>(areaTotal),
      'idFundo': serializer.toJson<String>(idFundo),
      'idVariedad': serializer.toJson<int>(idVariedad),
      'ceco': serializer.toJson<String>(ceco),
      'geomWkt': serializer.toJson<String?>(geomWkt),
      'minLat': serializer.toJson<double?>(minLat),
      'minLon': serializer.toJson<double?>(minLon),
      'maxLat': serializer.toJson<double?>(maxLat),
      'maxLon': serializer.toJson<double?>(maxLon),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  LotesTableData copyWith({
    int? idLote,
    String? descripcion,
    Value<String?> codigoLote = const Value.absent(),
    Value<String?> lote = const Value.absent(),
    Value<String?> subLote = const Value.absent(),
    Value<String?> cultivo = const Value.absent(),
    bool? estado,
    Value<double?> areaTotal = const Value.absent(),
    String? idFundo,
    int? idVariedad,
    String? ceco,
    Value<String?> geomWkt = const Value.absent(),
    Value<double?> minLat = const Value.absent(),
    Value<double?> minLon = const Value.absent(),
    Value<double?> maxLat = const Value.absent(),
    Value<double?> maxLon = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => LotesTableData(
    idLote: idLote ?? this.idLote,
    descripcion: descripcion ?? this.descripcion,
    codigoLote: codigoLote.present ? codigoLote.value : this.codigoLote,
    lote: lote.present ? lote.value : this.lote,
    subLote: subLote.present ? subLote.value : this.subLote,
    cultivo: cultivo.present ? cultivo.value : this.cultivo,
    estado: estado ?? this.estado,
    areaTotal: areaTotal.present ? areaTotal.value : this.areaTotal,
    idFundo: idFundo ?? this.idFundo,
    idVariedad: idVariedad ?? this.idVariedad,
    ceco: ceco ?? this.ceco,
    geomWkt: geomWkt.present ? geomWkt.value : this.geomWkt,
    minLat: minLat.present ? minLat.value : this.minLat,
    minLon: minLon.present ? minLon.value : this.minLon,
    maxLat: maxLat.present ? maxLat.value : this.maxLat,
    maxLon: maxLon.present ? maxLon.value : this.maxLon,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  LotesTableData copyWithCompanion(LotesTableCompanion data) {
    return LotesTableData(
      idLote: data.idLote.present ? data.idLote.value : this.idLote,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      codigoLote: data.codigoLote.present
          ? data.codigoLote.value
          : this.codigoLote,
      lote: data.lote.present ? data.lote.value : this.lote,
      subLote: data.subLote.present ? data.subLote.value : this.subLote,
      cultivo: data.cultivo.present ? data.cultivo.value : this.cultivo,
      estado: data.estado.present ? data.estado.value : this.estado,
      areaTotal: data.areaTotal.present ? data.areaTotal.value : this.areaTotal,
      idFundo: data.idFundo.present ? data.idFundo.value : this.idFundo,
      idVariedad: data.idVariedad.present
          ? data.idVariedad.value
          : this.idVariedad,
      ceco: data.ceco.present ? data.ceco.value : this.ceco,
      geomWkt: data.geomWkt.present ? data.geomWkt.value : this.geomWkt,
      minLat: data.minLat.present ? data.minLat.value : this.minLat,
      minLon: data.minLon.present ? data.minLon.value : this.minLon,
      maxLat: data.maxLat.present ? data.maxLat.value : this.maxLat,
      maxLon: data.maxLon.present ? data.maxLon.value : this.maxLon,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LotesTableData(')
          ..write('idLote: $idLote, ')
          ..write('descripcion: $descripcion, ')
          ..write('codigoLote: $codigoLote, ')
          ..write('lote: $lote, ')
          ..write('subLote: $subLote, ')
          ..write('cultivo: $cultivo, ')
          ..write('estado: $estado, ')
          ..write('areaTotal: $areaTotal, ')
          ..write('idFundo: $idFundo, ')
          ..write('idVariedad: $idVariedad, ')
          ..write('ceco: $ceco, ')
          ..write('geomWkt: $geomWkt, ')
          ..write('minLat: $minLat, ')
          ..write('minLon: $minLon, ')
          ..write('maxLat: $maxLat, ')
          ..write('maxLon: $maxLon, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idLote,
    descripcion,
    codigoLote,
    lote,
    subLote,
    cultivo,
    estado,
    areaTotal,
    idFundo,
    idVariedad,
    ceco,
    geomWkt,
    minLat,
    minLon,
    maxLat,
    maxLon,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LotesTableData &&
          other.idLote == this.idLote &&
          other.descripcion == this.descripcion &&
          other.codigoLote == this.codigoLote &&
          other.lote == this.lote &&
          other.subLote == this.subLote &&
          other.cultivo == this.cultivo &&
          other.estado == this.estado &&
          other.areaTotal == this.areaTotal &&
          other.idFundo == this.idFundo &&
          other.idVariedad == this.idVariedad &&
          other.ceco == this.ceco &&
          other.geomWkt == this.geomWkt &&
          other.minLat == this.minLat &&
          other.minLon == this.minLon &&
          other.maxLat == this.maxLat &&
          other.maxLon == this.maxLon &&
          other.updatedAt == this.updatedAt);
}

class LotesTableCompanion extends UpdateCompanion<LotesTableData> {
  final Value<int> idLote;
  final Value<String> descripcion;
  final Value<String?> codigoLote;
  final Value<String?> lote;
  final Value<String?> subLote;
  final Value<String?> cultivo;
  final Value<bool> estado;
  final Value<double?> areaTotal;
  final Value<String> idFundo;
  final Value<int> idVariedad;
  final Value<String> ceco;
  final Value<String?> geomWkt;
  final Value<double?> minLat;
  final Value<double?> minLon;
  final Value<double?> maxLat;
  final Value<double?> maxLon;
  final Value<int?> updatedAt;
  const LotesTableCompanion({
    this.idLote = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.codigoLote = const Value.absent(),
    this.lote = const Value.absent(),
    this.subLote = const Value.absent(),
    this.cultivo = const Value.absent(),
    this.estado = const Value.absent(),
    this.areaTotal = const Value.absent(),
    this.idFundo = const Value.absent(),
    this.idVariedad = const Value.absent(),
    this.ceco = const Value.absent(),
    this.geomWkt = const Value.absent(),
    this.minLat = const Value.absent(),
    this.minLon = const Value.absent(),
    this.maxLat = const Value.absent(),
    this.maxLon = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LotesTableCompanion.insert({
    this.idLote = const Value.absent(),
    required String descripcion,
    this.codigoLote = const Value.absent(),
    this.lote = const Value.absent(),
    this.subLote = const Value.absent(),
    this.cultivo = const Value.absent(),
    this.estado = const Value.absent(),
    this.areaTotal = const Value.absent(),
    required String idFundo,
    required int idVariedad,
    required String ceco,
    this.geomWkt = const Value.absent(),
    this.minLat = const Value.absent(),
    this.minLon = const Value.absent(),
    this.maxLat = const Value.absent(),
    this.maxLon = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : descripcion = Value(descripcion),
       idFundo = Value(idFundo),
       idVariedad = Value(idVariedad),
       ceco = Value(ceco);
  static Insertable<LotesTableData> custom({
    Expression<int>? idLote,
    Expression<String>? descripcion,
    Expression<String>? codigoLote,
    Expression<String>? lote,
    Expression<String>? subLote,
    Expression<String>? cultivo,
    Expression<bool>? estado,
    Expression<double>? areaTotal,
    Expression<String>? idFundo,
    Expression<int>? idVariedad,
    Expression<String>? ceco,
    Expression<String>? geomWkt,
    Expression<double>? minLat,
    Expression<double>? minLon,
    Expression<double>? maxLat,
    Expression<double>? maxLon,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (idLote != null) 'id_lote': idLote,
      if (descripcion != null) 'descripcion': descripcion,
      if (codigoLote != null) 'codigo_lote': codigoLote,
      if (lote != null) 'lote': lote,
      if (subLote != null) 'sub_lote': subLote,
      if (cultivo != null) 'cultivo': cultivo,
      if (estado != null) 'estado': estado,
      if (areaTotal != null) 'area_total': areaTotal,
      if (idFundo != null) 'id_fundo': idFundo,
      if (idVariedad != null) 'id_variedad': idVariedad,
      if (ceco != null) 'ceco': ceco,
      if (geomWkt != null) 'geom_wkt': geomWkt,
      if (minLat != null) 'min_lat': minLat,
      if (minLon != null) 'min_lon': minLon,
      if (maxLat != null) 'max_lat': maxLat,
      if (maxLon != null) 'max_lon': maxLon,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LotesTableCompanion copyWith({
    Value<int>? idLote,
    Value<String>? descripcion,
    Value<String?>? codigoLote,
    Value<String?>? lote,
    Value<String?>? subLote,
    Value<String?>? cultivo,
    Value<bool>? estado,
    Value<double?>? areaTotal,
    Value<String>? idFundo,
    Value<int>? idVariedad,
    Value<String>? ceco,
    Value<String?>? geomWkt,
    Value<double?>? minLat,
    Value<double?>? minLon,
    Value<double?>? maxLat,
    Value<double?>? maxLon,
    Value<int?>? updatedAt,
  }) {
    return LotesTableCompanion(
      idLote: idLote ?? this.idLote,
      descripcion: descripcion ?? this.descripcion,
      codigoLote: codigoLote ?? this.codigoLote,
      lote: lote ?? this.lote,
      subLote: subLote ?? this.subLote,
      cultivo: cultivo ?? this.cultivo,
      estado: estado ?? this.estado,
      areaTotal: areaTotal ?? this.areaTotal,
      idFundo: idFundo ?? this.idFundo,
      idVariedad: idVariedad ?? this.idVariedad,
      ceco: ceco ?? this.ceco,
      geomWkt: geomWkt ?? this.geomWkt,
      minLat: minLat ?? this.minLat,
      minLon: minLon ?? this.minLon,
      maxLat: maxLat ?? this.maxLat,
      maxLon: maxLon ?? this.maxLon,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idLote.present) {
      map['id_lote'] = Variable<int>(idLote.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (codigoLote.present) {
      map['codigo_lote'] = Variable<String>(codigoLote.value);
    }
    if (lote.present) {
      map['lote'] = Variable<String>(lote.value);
    }
    if (subLote.present) {
      map['sub_lote'] = Variable<String>(subLote.value);
    }
    if (cultivo.present) {
      map['cultivo'] = Variable<String>(cultivo.value);
    }
    if (estado.present) {
      map['estado'] = Variable<bool>(estado.value);
    }
    if (areaTotal.present) {
      map['area_total'] = Variable<double>(areaTotal.value);
    }
    if (idFundo.present) {
      map['id_fundo'] = Variable<String>(idFundo.value);
    }
    if (idVariedad.present) {
      map['id_variedad'] = Variable<int>(idVariedad.value);
    }
    if (ceco.present) {
      map['ceco'] = Variable<String>(ceco.value);
    }
    if (geomWkt.present) {
      map['geom_wkt'] = Variable<String>(geomWkt.value);
    }
    if (minLat.present) {
      map['min_lat'] = Variable<double>(minLat.value);
    }
    if (minLon.present) {
      map['min_lon'] = Variable<double>(minLon.value);
    }
    if (maxLat.present) {
      map['max_lat'] = Variable<double>(maxLat.value);
    }
    if (maxLon.present) {
      map['max_lon'] = Variable<double>(maxLon.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotesTableCompanion(')
          ..write('idLote: $idLote, ')
          ..write('descripcion: $descripcion, ')
          ..write('codigoLote: $codigoLote, ')
          ..write('lote: $lote, ')
          ..write('subLote: $subLote, ')
          ..write('cultivo: $cultivo, ')
          ..write('estado: $estado, ')
          ..write('areaTotal: $areaTotal, ')
          ..write('idFundo: $idFundo, ')
          ..write('idVariedad: $idVariedad, ')
          ..write('ceco: $ceco, ')
          ..write('geomWkt: $geomWkt, ')
          ..write('minLat: $minLat, ')
          ..write('minLon: $minLon, ')
          ..write('maxLat: $maxLat, ')
          ..write('maxLon: $maxLon, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LoteOrillasTableTable extends LoteOrillasTable
    with TableInfo<$LoteOrillasTableTable, LoteOrillasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoteOrillasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idLoteOrillaMeta = const VerificationMeta(
    'idLoteOrilla',
  );
  @override
  late final GeneratedColumn<int> idLoteOrilla = GeneratedColumn<int>(
    'id_lote_orilla',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idLoteMeta = const VerificationMeta('idLote');
  @override
  late final GeneratedColumn<int> idLote = GeneratedColumn<int>(
    'id_lote',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orillaCodigoMeta = const VerificationMeta(
    'orillaCodigo',
  );
  @override
  late final GeneratedColumn<String> orillaCodigo = GeneratedColumn<String>(
    'orilla_codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orillaLabelMeta = const VerificationMeta(
    'orillaLabel',
  );
  @override
  late final GeneratedColumn<String> orillaLabel = GeneratedColumn<String>(
    'orilla_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perimetralDescripcionMeta =
      const VerificationMeta('perimetralDescripcion');
  @override
  late final GeneratedColumn<String> perimetralDescripcion =
      GeneratedColumn<String>(
        'perimetral_descripcion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    idLoteOrilla,
    idLote,
    orillaCodigo,
    orillaLabel,
    perimetralDescripcion,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lote_orillas_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoteOrillasTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_lote_orilla')) {
      context.handle(
        _idLoteOrillaMeta,
        idLoteOrilla.isAcceptableOrUnknown(
          data['id_lote_orilla']!,
          _idLoteOrillaMeta,
        ),
      );
    }
    if (data.containsKey('id_lote')) {
      context.handle(
        _idLoteMeta,
        idLote.isAcceptableOrUnknown(data['id_lote']!, _idLoteMeta),
      );
    } else if (isInserting) {
      context.missing(_idLoteMeta);
    }
    if (data.containsKey('orilla_codigo')) {
      context.handle(
        _orillaCodigoMeta,
        orillaCodigo.isAcceptableOrUnknown(
          data['orilla_codigo']!,
          _orillaCodigoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orillaCodigoMeta);
    }
    if (data.containsKey('orilla_label')) {
      context.handle(
        _orillaLabelMeta,
        orillaLabel.isAcceptableOrUnknown(
          data['orilla_label']!,
          _orillaLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orillaLabelMeta);
    }
    if (data.containsKey('perimetral_descripcion')) {
      context.handle(
        _perimetralDescripcionMeta,
        perimetralDescripcion.isAcceptableOrUnknown(
          data['perimetral_descripcion']!,
          _perimetralDescripcionMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idLoteOrilla};
  @override
  LoteOrillasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoteOrillasTableData(
      idLoteOrilla: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_lote_orilla'],
      )!,
      idLote: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id_lote'],
      )!,
      orillaCodigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orilla_codigo'],
      )!,
      orillaLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orilla_label'],
      )!,
      perimetralDescripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}perimetral_descripcion'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $LoteOrillasTableTable createAlias(String alias) {
    return $LoteOrillasTableTable(attachedDatabase, alias);
  }
}

class LoteOrillasTableData extends DataClass
    implements Insertable<LoteOrillasTableData> {
  final int idLoteOrilla;
  final int idLote;
  final String orillaCodigo;
  final String orillaLabel;
  final String? perimetralDescripcion;
  final bool activo;
  const LoteOrillasTableData({
    required this.idLoteOrilla,
    required this.idLote,
    required this.orillaCodigo,
    required this.orillaLabel,
    this.perimetralDescripcion,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_lote_orilla'] = Variable<int>(idLoteOrilla);
    map['id_lote'] = Variable<int>(idLote);
    map['orilla_codigo'] = Variable<String>(orillaCodigo);
    map['orilla_label'] = Variable<String>(orillaLabel);
    if (!nullToAbsent || perimetralDescripcion != null) {
      map['perimetral_descripcion'] = Variable<String>(perimetralDescripcion);
    }
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  LoteOrillasTableCompanion toCompanion(bool nullToAbsent) {
    return LoteOrillasTableCompanion(
      idLoteOrilla: Value(idLoteOrilla),
      idLote: Value(idLote),
      orillaCodigo: Value(orillaCodigo),
      orillaLabel: Value(orillaLabel),
      perimetralDescripcion: perimetralDescripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(perimetralDescripcion),
      activo: Value(activo),
    );
  }

  factory LoteOrillasTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoteOrillasTableData(
      idLoteOrilla: serializer.fromJson<int>(json['idLoteOrilla']),
      idLote: serializer.fromJson<int>(json['idLote']),
      orillaCodigo: serializer.fromJson<String>(json['orillaCodigo']),
      orillaLabel: serializer.fromJson<String>(json['orillaLabel']),
      perimetralDescripcion: serializer.fromJson<String?>(
        json['perimetralDescripcion'],
      ),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idLoteOrilla': serializer.toJson<int>(idLoteOrilla),
      'idLote': serializer.toJson<int>(idLote),
      'orillaCodigo': serializer.toJson<String>(orillaCodigo),
      'orillaLabel': serializer.toJson<String>(orillaLabel),
      'perimetralDescripcion': serializer.toJson<String?>(
        perimetralDescripcion,
      ),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  LoteOrillasTableData copyWith({
    int? idLoteOrilla,
    int? idLote,
    String? orillaCodigo,
    String? orillaLabel,
    Value<String?> perimetralDescripcion = const Value.absent(),
    bool? activo,
  }) => LoteOrillasTableData(
    idLoteOrilla: idLoteOrilla ?? this.idLoteOrilla,
    idLote: idLote ?? this.idLote,
    orillaCodigo: orillaCodigo ?? this.orillaCodigo,
    orillaLabel: orillaLabel ?? this.orillaLabel,
    perimetralDescripcion: perimetralDescripcion.present
        ? perimetralDescripcion.value
        : this.perimetralDescripcion,
    activo: activo ?? this.activo,
  );
  LoteOrillasTableData copyWithCompanion(LoteOrillasTableCompanion data) {
    return LoteOrillasTableData(
      idLoteOrilla: data.idLoteOrilla.present
          ? data.idLoteOrilla.value
          : this.idLoteOrilla,
      idLote: data.idLote.present ? data.idLote.value : this.idLote,
      orillaCodigo: data.orillaCodigo.present
          ? data.orillaCodigo.value
          : this.orillaCodigo,
      orillaLabel: data.orillaLabel.present
          ? data.orillaLabel.value
          : this.orillaLabel,
      perimetralDescripcion: data.perimetralDescripcion.present
          ? data.perimetralDescripcion.value
          : this.perimetralDescripcion,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoteOrillasTableData(')
          ..write('idLoteOrilla: $idLoteOrilla, ')
          ..write('idLote: $idLote, ')
          ..write('orillaCodigo: $orillaCodigo, ')
          ..write('orillaLabel: $orillaLabel, ')
          ..write('perimetralDescripcion: $perimetralDescripcion, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idLoteOrilla,
    idLote,
    orillaCodigo,
    orillaLabel,
    perimetralDescripcion,
    activo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoteOrillasTableData &&
          other.idLoteOrilla == this.idLoteOrilla &&
          other.idLote == this.idLote &&
          other.orillaCodigo == this.orillaCodigo &&
          other.orillaLabel == this.orillaLabel &&
          other.perimetralDescripcion == this.perimetralDescripcion &&
          other.activo == this.activo);
}

class LoteOrillasTableCompanion extends UpdateCompanion<LoteOrillasTableData> {
  final Value<int> idLoteOrilla;
  final Value<int> idLote;
  final Value<String> orillaCodigo;
  final Value<String> orillaLabel;
  final Value<String?> perimetralDescripcion;
  final Value<bool> activo;
  const LoteOrillasTableCompanion({
    this.idLoteOrilla = const Value.absent(),
    this.idLote = const Value.absent(),
    this.orillaCodigo = const Value.absent(),
    this.orillaLabel = const Value.absent(),
    this.perimetralDescripcion = const Value.absent(),
    this.activo = const Value.absent(),
  });
  LoteOrillasTableCompanion.insert({
    this.idLoteOrilla = const Value.absent(),
    required int idLote,
    required String orillaCodigo,
    required String orillaLabel,
    this.perimetralDescripcion = const Value.absent(),
    this.activo = const Value.absent(),
  }) : idLote = Value(idLote),
       orillaCodigo = Value(orillaCodigo),
       orillaLabel = Value(orillaLabel);
  static Insertable<LoteOrillasTableData> custom({
    Expression<int>? idLoteOrilla,
    Expression<int>? idLote,
    Expression<String>? orillaCodigo,
    Expression<String>? orillaLabel,
    Expression<String>? perimetralDescripcion,
    Expression<bool>? activo,
  }) {
    return RawValuesInsertable({
      if (idLoteOrilla != null) 'id_lote_orilla': idLoteOrilla,
      if (idLote != null) 'id_lote': idLote,
      if (orillaCodigo != null) 'orilla_codigo': orillaCodigo,
      if (orillaLabel != null) 'orilla_label': orillaLabel,
      if (perimetralDescripcion != null)
        'perimetral_descripcion': perimetralDescripcion,
      if (activo != null) 'activo': activo,
    });
  }

  LoteOrillasTableCompanion copyWith({
    Value<int>? idLoteOrilla,
    Value<int>? idLote,
    Value<String>? orillaCodigo,
    Value<String>? orillaLabel,
    Value<String?>? perimetralDescripcion,
    Value<bool>? activo,
  }) {
    return LoteOrillasTableCompanion(
      idLoteOrilla: idLoteOrilla ?? this.idLoteOrilla,
      idLote: idLote ?? this.idLote,
      orillaCodigo: orillaCodigo ?? this.orillaCodigo,
      orillaLabel: orillaLabel ?? this.orillaLabel,
      perimetralDescripcion:
          perimetralDescripcion ?? this.perimetralDescripcion,
      activo: activo ?? this.activo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idLoteOrilla.present) {
      map['id_lote_orilla'] = Variable<int>(idLoteOrilla.value);
    }
    if (idLote.present) {
      map['id_lote'] = Variable<int>(idLote.value);
    }
    if (orillaCodigo.present) {
      map['orilla_codigo'] = Variable<String>(orillaCodigo.value);
    }
    if (orillaLabel.present) {
      map['orilla_label'] = Variable<String>(orillaLabel.value);
    }
    if (perimetralDescripcion.present) {
      map['perimetral_descripcion'] = Variable<String>(
        perimetralDescripcion.value,
      );
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoteOrillasTableCompanion(')
          ..write('idLoteOrilla: $idLoteOrilla, ')
          ..write('idLote: $idLote, ')
          ..write('orillaCodigo: $orillaCodigo, ')
          ..write('orillaLabel: $orillaLabel, ')
          ..write('perimetralDescripcion: $perimetralDescripcion, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }
}

class $VariedadesTableTable extends VariedadesTable
    with TableInfo<$VariedadesTableTable, VariedadesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VariedadesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCreacionMeta = const VerificationMeta(
    'fechaCreacion',
  );
  @override
  late final GeneratedColumn<String> fechaCreacion = GeneratedColumn<String>(
    'fecha_creacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, descripcion, fechaCreacion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'variedades_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<VariedadesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
        _fechaCreacionMeta,
        fechaCreacion.isAcceptableOrUnknown(
          data['fecha_creacion']!,
          _fechaCreacionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VariedadesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VariedadesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      fechaCreacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha_creacion'],
      ),
    );
  }

  @override
  $VariedadesTableTable createAlias(String alias) {
    return $VariedadesTableTable(attachedDatabase, alias);
  }
}

class VariedadesTableData extends DataClass
    implements Insertable<VariedadesTableData> {
  final int id;
  final String descripcion;
  final String? fechaCreacion;
  const VariedadesTableData({
    required this.id,
    required this.descripcion,
    this.fechaCreacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['descripcion'] = Variable<String>(descripcion);
    if (!nullToAbsent || fechaCreacion != null) {
      map['fecha_creacion'] = Variable<String>(fechaCreacion);
    }
    return map;
  }

  VariedadesTableCompanion toCompanion(bool nullToAbsent) {
    return VariedadesTableCompanion(
      id: Value(id),
      descripcion: Value(descripcion),
      fechaCreacion: fechaCreacion == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCreacion),
    );
  }

  factory VariedadesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VariedadesTableData(
      id: serializer.fromJson<int>(json['id']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      fechaCreacion: serializer.fromJson<String?>(json['fechaCreacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'descripcion': serializer.toJson<String>(descripcion),
      'fechaCreacion': serializer.toJson<String?>(fechaCreacion),
    };
  }

  VariedadesTableData copyWith({
    int? id,
    String? descripcion,
    Value<String?> fechaCreacion = const Value.absent(),
  }) => VariedadesTableData(
    id: id ?? this.id,
    descripcion: descripcion ?? this.descripcion,
    fechaCreacion: fechaCreacion.present
        ? fechaCreacion.value
        : this.fechaCreacion,
  );
  VariedadesTableData copyWithCompanion(VariedadesTableCompanion data) {
    return VariedadesTableData(
      id: data.id.present ? data.id.value : this.id,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VariedadesTableData(')
          ..write('id: $id, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, descripcion, fechaCreacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VariedadesTableData &&
          other.id == this.id &&
          other.descripcion == this.descripcion &&
          other.fechaCreacion == this.fechaCreacion);
}

class VariedadesTableCompanion extends UpdateCompanion<VariedadesTableData> {
  final Value<int> id;
  final Value<String> descripcion;
  final Value<String?> fechaCreacion;
  const VariedadesTableCompanion({
    this.id = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
  });
  VariedadesTableCompanion.insert({
    this.id = const Value.absent(),
    required String descripcion,
    this.fechaCreacion = const Value.absent(),
  }) : descripcion = Value(descripcion);
  static Insertable<VariedadesTableData> custom({
    Expression<int>? id,
    Expression<String>? descripcion,
    Expression<String>? fechaCreacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (descripcion != null) 'descripcion': descripcion,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
    });
  }

  VariedadesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? descripcion,
    Value<String?>? fechaCreacion,
  }) {
    return VariedadesTableCompanion(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<String>(fechaCreacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VariedadesTableCompanion(')
          ..write('id: $id, ')
          ..write('descripcion: $descripcion, ')
          ..write('fechaCreacion: $fechaCreacion')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RegistrosLocalTable registrosLocal = $RegistrosLocalTable(this);
  late final $PlantillasLocalTable plantillasLocal = $PlantillasLocalTable(
    this,
  );
  late final $SyncCursorLocalTable syncCursorLocal = $SyncCursorLocalTable(
    this,
  );
  late final $CampaniasTableTable campaniasTable = $CampaniasTableTable(this);
  late final $LotesTableTable lotesTable = $LotesTableTable(this);
  late final $LoteOrillasTableTable loteOrillasTable = $LoteOrillasTableTable(
    this,
  );
  late final $VariedadesTableTable variedadesTable = $VariedadesTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    registrosLocal,
    plantillasLocal,
    syncCursorLocal,
    campaniasTable,
    lotesTable,
    loteOrillasTable,
    variedadesTable,
  ];
}

typedef $$RegistrosLocalTableCreateCompanionBuilder =
    RegistrosLocalCompanion Function({
      Value<int> localId,
      Value<int?> serverId,
      required int plantillaId,
      Value<String> templateKey,
      required int userId,
      Value<String?> campaniaId,
      Value<int?> loteId,
      Value<double?> lat,
      Value<double?> lon,
      Value<String> estado,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> syncAttempts,
      Value<String> dataJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$RegistrosLocalTableUpdateCompanionBuilder =
    RegistrosLocalCompanion Function({
      Value<int> localId,
      Value<int?> serverId,
      Value<int> plantillaId,
      Value<String> templateKey,
      Value<int> userId,
      Value<String?> campaniaId,
      Value<int?> loteId,
      Value<double?> lat,
      Value<double?> lon,
      Value<String> estado,
      Value<String> syncStatus,
      Value<String?> syncError,
      Value<int> syncAttempts,
      Value<String> dataJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

class $$RegistrosLocalTableFilterComposer
    extends Composer<_$AppDatabase, $RegistrosLocalTable> {
  $$RegistrosLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plantillaId => $composableBuilder(
    column: $table.plantillaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campaniaId => $composableBuilder(
    column: $table.campaniaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncAttempts => $composableBuilder(
    column: $table.syncAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RegistrosLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $RegistrosLocalTable> {
  $$RegistrosLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plantillaId => $composableBuilder(
    column: $table.plantillaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campaniaId => $composableBuilder(
    column: $table.campaniaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get loteId => $composableBuilder(
    column: $table.loteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncError => $composableBuilder(
    column: $table.syncError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncAttempts => $composableBuilder(
    column: $table.syncAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RegistrosLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegistrosLocalTable> {
  $$RegistrosLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get plantillaId => $composableBuilder(
    column: $table.plantillaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get campaniaId => $composableBuilder(
    column: $table.campaniaId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get loteId =>
      $composableBuilder(column: $table.loteId, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);

  GeneratedColumn<int> get syncAttempts => $composableBuilder(
    column: $table.syncAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$RegistrosLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RegistrosLocalTable,
          RegistrosLocalData,
          $$RegistrosLocalTableFilterComposer,
          $$RegistrosLocalTableOrderingComposer,
          $$RegistrosLocalTableAnnotationComposer,
          $$RegistrosLocalTableCreateCompanionBuilder,
          $$RegistrosLocalTableUpdateCompanionBuilder,
          (
            RegistrosLocalData,
            BaseReferences<
              _$AppDatabase,
              $RegistrosLocalTable,
              RegistrosLocalData
            >,
          ),
          RegistrosLocalData,
          PrefetchHooks Function()
        > {
  $$RegistrosLocalTableTableManager(
    _$AppDatabase db,
    $RegistrosLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrosLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrosLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistrosLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> plantillaId = const Value.absent(),
                Value<String> templateKey = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> campaniaId = const Value.absent(),
                Value<int?> loteId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> syncAttempts = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RegistrosLocalCompanion(
                localId: localId,
                serverId: serverId,
                plantillaId: plantillaId,
                templateKey: templateKey,
                userId: userId,
                campaniaId: campaniaId,
                loteId: loteId,
                lat: lat,
                lon: lon,
                estado: estado,
                syncStatus: syncStatus,
                syncError: syncError,
                syncAttempts: syncAttempts,
                dataJson: dataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required int plantillaId,
                Value<String> templateKey = const Value.absent(),
                required int userId,
                Value<String?> campaniaId = const Value.absent(),
                Value<int?> loteId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lon = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> syncError = const Value.absent(),
                Value<int> syncAttempts = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RegistrosLocalCompanion.insert(
                localId: localId,
                serverId: serverId,
                plantillaId: plantillaId,
                templateKey: templateKey,
                userId: userId,
                campaniaId: campaniaId,
                loteId: loteId,
                lat: lat,
                lon: lon,
                estado: estado,
                syncStatus: syncStatus,
                syncError: syncError,
                syncAttempts: syncAttempts,
                dataJson: dataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RegistrosLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RegistrosLocalTable,
      RegistrosLocalData,
      $$RegistrosLocalTableFilterComposer,
      $$RegistrosLocalTableOrderingComposer,
      $$RegistrosLocalTableAnnotationComposer,
      $$RegistrosLocalTableCreateCompanionBuilder,
      $$RegistrosLocalTableUpdateCompanionBuilder,
      (
        RegistrosLocalData,
        BaseReferences<_$AppDatabase, $RegistrosLocalTable, RegistrosLocalData>,
      ),
      RegistrosLocalData,
      PrefetchHooks Function()
    >;
typedef $$PlantillasLocalTableCreateCompanionBuilder =
    PlantillasLocalCompanion Function({
      required int plantillaId,
      required int userId,
      Value<String?> codigo,
      Value<String?> nombre,
      Value<String?> descripcion,
      Value<int> version,
      Value<bool> isActive,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PlantillasLocalTableUpdateCompanionBuilder =
    PlantillasLocalCompanion Function({
      Value<int> plantillaId,
      Value<int> userId,
      Value<String?> codigo,
      Value<String?> nombre,
      Value<String?> descripcion,
      Value<int> version,
      Value<bool> isActive,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$PlantillasLocalTableFilterComposer
    extends Composer<_$AppDatabase, $PlantillasLocalTable> {
  $$PlantillasLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get plantillaId => $composableBuilder(
    column: $table.plantillaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlantillasLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $PlantillasLocalTable> {
  $$PlantillasLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get plantillaId => $composableBuilder(
    column: $table.plantillaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlantillasLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlantillasLocalTable> {
  $$PlantillasLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get plantillaId => $composableBuilder(
    column: $table.plantillaId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PlantillasLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlantillasLocalTable,
          PlantillasLocalData,
          $$PlantillasLocalTableFilterComposer,
          $$PlantillasLocalTableOrderingComposer,
          $$PlantillasLocalTableAnnotationComposer,
          $$PlantillasLocalTableCreateCompanionBuilder,
          $$PlantillasLocalTableUpdateCompanionBuilder,
          (
            PlantillasLocalData,
            BaseReferences<
              _$AppDatabase,
              $PlantillasLocalTable,
              PlantillasLocalData
            >,
          ),
          PlantillasLocalData,
          PrefetchHooks Function()
        > {
  $$PlantillasLocalTableTableManager(
    _$AppDatabase db,
    $PlantillasLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlantillasLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlantillasLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlantillasLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> plantillaId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> codigo = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantillasLocalCompanion(
                plantillaId: plantillaId,
                userId: userId,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                version: version,
                isActive: isActive,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int plantillaId,
                required int userId,
                Value<String?> codigo = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlantillasLocalCompanion.insert(
                plantillaId: plantillaId,
                userId: userId,
                codigo: codigo,
                nombre: nombre,
                descripcion: descripcion,
                version: version,
                isActive: isActive,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlantillasLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlantillasLocalTable,
      PlantillasLocalData,
      $$PlantillasLocalTableFilterComposer,
      $$PlantillasLocalTableOrderingComposer,
      $$PlantillasLocalTableAnnotationComposer,
      $$PlantillasLocalTableCreateCompanionBuilder,
      $$PlantillasLocalTableUpdateCompanionBuilder,
      (
        PlantillasLocalData,
        BaseReferences<
          _$AppDatabase,
          $PlantillasLocalTable,
          PlantillasLocalData
        >,
      ),
      PlantillasLocalData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorLocalTableCreateCompanionBuilder =
    SyncCursorLocalCompanion Function({
      required String key,
      required DateTime value,
      Value<int> rowid,
    });
typedef $$SyncCursorLocalTableUpdateCompanionBuilder =
    SyncCursorLocalCompanion Function({
      Value<String> key,
      Value<DateTime> value,
      Value<int> rowid,
    });

class $$SyncCursorLocalTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorLocalTable> {
  $$SyncCursorLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorLocalTable> {
  $$SyncCursorLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorLocalTable> {
  $$SyncCursorLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncCursorLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorLocalTable,
          SyncCursorLocalData,
          $$SyncCursorLocalTableFilterComposer,
          $$SyncCursorLocalTableOrderingComposer,
          $$SyncCursorLocalTableAnnotationComposer,
          $$SyncCursorLocalTableCreateCompanionBuilder,
          $$SyncCursorLocalTableUpdateCompanionBuilder,
          (
            SyncCursorLocalData,
            BaseReferences<
              _$AppDatabase,
              $SyncCursorLocalTable,
              SyncCursorLocalData
            >,
          ),
          SyncCursorLocalData,
          PrefetchHooks Function()
        > {
  $$SyncCursorLocalTableTableManager(
    _$AppDatabase db,
    $SyncCursorLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<DateTime> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorLocalCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required DateTime value,
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorLocalCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorLocalTable,
      SyncCursorLocalData,
      $$SyncCursorLocalTableFilterComposer,
      $$SyncCursorLocalTableOrderingComposer,
      $$SyncCursorLocalTableAnnotationComposer,
      $$SyncCursorLocalTableCreateCompanionBuilder,
      $$SyncCursorLocalTableUpdateCompanionBuilder,
      (
        SyncCursorLocalData,
        BaseReferences<
          _$AppDatabase,
          $SyncCursorLocalTable,
          SyncCursorLocalData
        >,
      ),
      SyncCursorLocalData,
      PrefetchHooks Function()
    >;
typedef $$CampaniasTableTableCreateCompanionBuilder =
    CampaniasTableCompanion Function({
      required String idCampania,
      required String descripcion,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$CampaniasTableTableUpdateCompanionBuilder =
    CampaniasTableCompanion Function({
      Value<String> idCampania,
      Value<String> descripcion,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

class $$CampaniasTableTableFilterComposer
    extends Composer<_$AppDatabase, $CampaniasTableTable> {
  $$CampaniasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idCampania => $composableBuilder(
    column: $table.idCampania,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaniasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaniasTableTable> {
  $$CampaniasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idCampania => $composableBuilder(
    column: $table.idCampania,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaniasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaniasTableTable> {
  $$CampaniasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idCampania => $composableBuilder(
    column: $table.idCampania,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CampaniasTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampaniasTableTable,
          CampaniasTableData,
          $$CampaniasTableTableFilterComposer,
          $$CampaniasTableTableOrderingComposer,
          $$CampaniasTableTableAnnotationComposer,
          $$CampaniasTableTableCreateCompanionBuilder,
          $$CampaniasTableTableUpdateCompanionBuilder,
          (
            CampaniasTableData,
            BaseReferences<
              _$AppDatabase,
              $CampaniasTableTable,
              CampaniasTableData
            >,
          ),
          CampaniasTableData,
          PrefetchHooks Function()
        > {
  $$CampaniasTableTableTableManager(
    _$AppDatabase db,
    $CampaniasTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaniasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaniasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaniasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> idCampania = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaniasTableCompanion(
                idCampania: idCampania,
                descripcion: descripcion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idCampania,
                required String descripcion,
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaniasTableCompanion.insert(
                idCampania: idCampania,
                descripcion: descripcion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaniasTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampaniasTableTable,
      CampaniasTableData,
      $$CampaniasTableTableFilterComposer,
      $$CampaniasTableTableOrderingComposer,
      $$CampaniasTableTableAnnotationComposer,
      $$CampaniasTableTableCreateCompanionBuilder,
      $$CampaniasTableTableUpdateCompanionBuilder,
      (
        CampaniasTableData,
        BaseReferences<_$AppDatabase, $CampaniasTableTable, CampaniasTableData>,
      ),
      CampaniasTableData,
      PrefetchHooks Function()
    >;
typedef $$LotesTableTableCreateCompanionBuilder =
    LotesTableCompanion Function({
      Value<int> idLote,
      required String descripcion,
      Value<String?> codigoLote,
      Value<String?> lote,
      Value<String?> subLote,
      Value<String?> cultivo,
      Value<bool> estado,
      Value<double?> areaTotal,
      required String idFundo,
      required int idVariedad,
      required String ceco,
      Value<String?> geomWkt,
      Value<double?> minLat,
      Value<double?> minLon,
      Value<double?> maxLat,
      Value<double?> maxLon,
      Value<int?> updatedAt,
    });
typedef $$LotesTableTableUpdateCompanionBuilder =
    LotesTableCompanion Function({
      Value<int> idLote,
      Value<String> descripcion,
      Value<String?> codigoLote,
      Value<String?> lote,
      Value<String?> subLote,
      Value<String?> cultivo,
      Value<bool> estado,
      Value<double?> areaTotal,
      Value<String> idFundo,
      Value<int> idVariedad,
      Value<String> ceco,
      Value<String?> geomWkt,
      Value<double?> minLat,
      Value<double?> minLon,
      Value<double?> maxLat,
      Value<double?> maxLon,
      Value<int?> updatedAt,
    });

class $$LotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $LotesTableTable> {
  $$LotesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get idLote => $composableBuilder(
    column: $table.idLote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoLote => $composableBuilder(
    column: $table.codigoLote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lote => $composableBuilder(
    column: $table.lote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subLote => $composableBuilder(
    column: $table.subLote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cultivo => $composableBuilder(
    column: $table.cultivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaTotal => $composableBuilder(
    column: $table.areaTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idFundo => $composableBuilder(
    column: $table.idFundo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idVariedad => $composableBuilder(
    column: $table.idVariedad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ceco => $composableBuilder(
    column: $table.ceco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geomWkt => $composableBuilder(
    column: $table.geomWkt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minLat => $composableBuilder(
    column: $table.minLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minLon => $composableBuilder(
    column: $table.minLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxLat => $composableBuilder(
    column: $table.maxLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxLon => $composableBuilder(
    column: $table.maxLon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LotesTableTable> {
  $$LotesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get idLote => $composableBuilder(
    column: $table.idLote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoLote => $composableBuilder(
    column: $table.codigoLote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lote => $composableBuilder(
    column: $table.lote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subLote => $composableBuilder(
    column: $table.subLote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cultivo => $composableBuilder(
    column: $table.cultivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaTotal => $composableBuilder(
    column: $table.areaTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idFundo => $composableBuilder(
    column: $table.idFundo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idVariedad => $composableBuilder(
    column: $table.idVariedad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ceco => $composableBuilder(
    column: $table.ceco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geomWkt => $composableBuilder(
    column: $table.geomWkt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minLat => $composableBuilder(
    column: $table.minLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minLon => $composableBuilder(
    column: $table.minLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxLat => $composableBuilder(
    column: $table.maxLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxLon => $composableBuilder(
    column: $table.maxLon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotesTableTable> {
  $$LotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get idLote =>
      $composableBuilder(column: $table.idLote, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigoLote => $composableBuilder(
    column: $table.codigoLote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lote =>
      $composableBuilder(column: $table.lote, builder: (column) => column);

  GeneratedColumn<String> get subLote =>
      $composableBuilder(column: $table.subLote, builder: (column) => column);

  GeneratedColumn<String> get cultivo =>
      $composableBuilder(column: $table.cultivo, builder: (column) => column);

  GeneratedColumn<bool> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<double> get areaTotal =>
      $composableBuilder(column: $table.areaTotal, builder: (column) => column);

  GeneratedColumn<String> get idFundo =>
      $composableBuilder(column: $table.idFundo, builder: (column) => column);

  GeneratedColumn<int> get idVariedad => $composableBuilder(
    column: $table.idVariedad,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ceco =>
      $composableBuilder(column: $table.ceco, builder: (column) => column);

  GeneratedColumn<String> get geomWkt =>
      $composableBuilder(column: $table.geomWkt, builder: (column) => column);

  GeneratedColumn<double> get minLat =>
      $composableBuilder(column: $table.minLat, builder: (column) => column);

  GeneratedColumn<double> get minLon =>
      $composableBuilder(column: $table.minLon, builder: (column) => column);

  GeneratedColumn<double> get maxLat =>
      $composableBuilder(column: $table.maxLat, builder: (column) => column);

  GeneratedColumn<double> get maxLon =>
      $composableBuilder(column: $table.maxLon, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LotesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotesTableTable,
          LotesTableData,
          $$LotesTableTableFilterComposer,
          $$LotesTableTableOrderingComposer,
          $$LotesTableTableAnnotationComposer,
          $$LotesTableTableCreateCompanionBuilder,
          $$LotesTableTableUpdateCompanionBuilder,
          (
            LotesTableData,
            BaseReferences<_$AppDatabase, $LotesTableTable, LotesTableData>,
          ),
          LotesTableData,
          PrefetchHooks Function()
        > {
  $$LotesTableTableTableManager(_$AppDatabase db, $LotesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> idLote = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<String?> codigoLote = const Value.absent(),
                Value<String?> lote = const Value.absent(),
                Value<String?> subLote = const Value.absent(),
                Value<String?> cultivo = const Value.absent(),
                Value<bool> estado = const Value.absent(),
                Value<double?> areaTotal = const Value.absent(),
                Value<String> idFundo = const Value.absent(),
                Value<int> idVariedad = const Value.absent(),
                Value<String> ceco = const Value.absent(),
                Value<String?> geomWkt = const Value.absent(),
                Value<double?> minLat = const Value.absent(),
                Value<double?> minLon = const Value.absent(),
                Value<double?> maxLat = const Value.absent(),
                Value<double?> maxLon = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => LotesTableCompanion(
                idLote: idLote,
                descripcion: descripcion,
                codigoLote: codigoLote,
                lote: lote,
                subLote: subLote,
                cultivo: cultivo,
                estado: estado,
                areaTotal: areaTotal,
                idFundo: idFundo,
                idVariedad: idVariedad,
                ceco: ceco,
                geomWkt: geomWkt,
                minLat: minLat,
                minLon: minLon,
                maxLat: maxLat,
                maxLon: maxLon,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> idLote = const Value.absent(),
                required String descripcion,
                Value<String?> codigoLote = const Value.absent(),
                Value<String?> lote = const Value.absent(),
                Value<String?> subLote = const Value.absent(),
                Value<String?> cultivo = const Value.absent(),
                Value<bool> estado = const Value.absent(),
                Value<double?> areaTotal = const Value.absent(),
                required String idFundo,
                required int idVariedad,
                required String ceco,
                Value<String?> geomWkt = const Value.absent(),
                Value<double?> minLat = const Value.absent(),
                Value<double?> minLon = const Value.absent(),
                Value<double?> maxLat = const Value.absent(),
                Value<double?> maxLon = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => LotesTableCompanion.insert(
                idLote: idLote,
                descripcion: descripcion,
                codigoLote: codigoLote,
                lote: lote,
                subLote: subLote,
                cultivo: cultivo,
                estado: estado,
                areaTotal: areaTotal,
                idFundo: idFundo,
                idVariedad: idVariedad,
                ceco: ceco,
                geomWkt: geomWkt,
                minLat: minLat,
                minLon: minLon,
                maxLat: maxLat,
                maxLon: maxLon,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotesTableTable,
      LotesTableData,
      $$LotesTableTableFilterComposer,
      $$LotesTableTableOrderingComposer,
      $$LotesTableTableAnnotationComposer,
      $$LotesTableTableCreateCompanionBuilder,
      $$LotesTableTableUpdateCompanionBuilder,
      (
        LotesTableData,
        BaseReferences<_$AppDatabase, $LotesTableTable, LotesTableData>,
      ),
      LotesTableData,
      PrefetchHooks Function()
    >;
typedef $$LoteOrillasTableTableCreateCompanionBuilder =
    LoteOrillasTableCompanion Function({
      Value<int> idLoteOrilla,
      required int idLote,
      required String orillaCodigo,
      required String orillaLabel,
      Value<String?> perimetralDescripcion,
      Value<bool> activo,
    });
typedef $$LoteOrillasTableTableUpdateCompanionBuilder =
    LoteOrillasTableCompanion Function({
      Value<int> idLoteOrilla,
      Value<int> idLote,
      Value<String> orillaCodigo,
      Value<String> orillaLabel,
      Value<String?> perimetralDescripcion,
      Value<bool> activo,
    });

class $$LoteOrillasTableTableFilterComposer
    extends Composer<_$AppDatabase, $LoteOrillasTableTable> {
  $$LoteOrillasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get idLoteOrilla => $composableBuilder(
    column: $table.idLoteOrilla,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idLote => $composableBuilder(
    column: $table.idLote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orillaCodigo => $composableBuilder(
    column: $table.orillaCodigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orillaLabel => $composableBuilder(
    column: $table.orillaLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get perimetralDescripcion => $composableBuilder(
    column: $table.perimetralDescripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoteOrillasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LoteOrillasTableTable> {
  $$LoteOrillasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get idLoteOrilla => $composableBuilder(
    column: $table.idLoteOrilla,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idLote => $composableBuilder(
    column: $table.idLote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orillaCodigo => $composableBuilder(
    column: $table.orillaCodigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orillaLabel => $composableBuilder(
    column: $table.orillaLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get perimetralDescripcion => $composableBuilder(
    column: $table.perimetralDescripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoteOrillasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoteOrillasTableTable> {
  $$LoteOrillasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get idLoteOrilla => $composableBuilder(
    column: $table.idLoteOrilla,
    builder: (column) => column,
  );

  GeneratedColumn<int> get idLote =>
      $composableBuilder(column: $table.idLote, builder: (column) => column);

  GeneratedColumn<String> get orillaCodigo => $composableBuilder(
    column: $table.orillaCodigo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orillaLabel => $composableBuilder(
    column: $table.orillaLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get perimetralDescripcion => $composableBuilder(
    column: $table.perimetralDescripcion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);
}

class $$LoteOrillasTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoteOrillasTableTable,
          LoteOrillasTableData,
          $$LoteOrillasTableTableFilterComposer,
          $$LoteOrillasTableTableOrderingComposer,
          $$LoteOrillasTableTableAnnotationComposer,
          $$LoteOrillasTableTableCreateCompanionBuilder,
          $$LoteOrillasTableTableUpdateCompanionBuilder,
          (
            LoteOrillasTableData,
            BaseReferences<
              _$AppDatabase,
              $LoteOrillasTableTable,
              LoteOrillasTableData
            >,
          ),
          LoteOrillasTableData,
          PrefetchHooks Function()
        > {
  $$LoteOrillasTableTableTableManager(
    _$AppDatabase db,
    $LoteOrillasTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoteOrillasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoteOrillasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoteOrillasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> idLoteOrilla = const Value.absent(),
                Value<int> idLote = const Value.absent(),
                Value<String> orillaCodigo = const Value.absent(),
                Value<String> orillaLabel = const Value.absent(),
                Value<String?> perimetralDescripcion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => LoteOrillasTableCompanion(
                idLoteOrilla: idLoteOrilla,
                idLote: idLote,
                orillaCodigo: orillaCodigo,
                orillaLabel: orillaLabel,
                perimetralDescripcion: perimetralDescripcion,
                activo: activo,
              ),
          createCompanionCallback:
              ({
                Value<int> idLoteOrilla = const Value.absent(),
                required int idLote,
                required String orillaCodigo,
                required String orillaLabel,
                Value<String?> perimetralDescripcion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
              }) => LoteOrillasTableCompanion.insert(
                idLoteOrilla: idLoteOrilla,
                idLote: idLote,
                orillaCodigo: orillaCodigo,
                orillaLabel: orillaLabel,
                perimetralDescripcion: perimetralDescripcion,
                activo: activo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoteOrillasTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoteOrillasTableTable,
      LoteOrillasTableData,
      $$LoteOrillasTableTableFilterComposer,
      $$LoteOrillasTableTableOrderingComposer,
      $$LoteOrillasTableTableAnnotationComposer,
      $$LoteOrillasTableTableCreateCompanionBuilder,
      $$LoteOrillasTableTableUpdateCompanionBuilder,
      (
        LoteOrillasTableData,
        BaseReferences<
          _$AppDatabase,
          $LoteOrillasTableTable,
          LoteOrillasTableData
        >,
      ),
      LoteOrillasTableData,
      PrefetchHooks Function()
    >;
typedef $$VariedadesTableTableCreateCompanionBuilder =
    VariedadesTableCompanion Function({
      Value<int> id,
      required String descripcion,
      Value<String?> fechaCreacion,
    });
typedef $$VariedadesTableTableUpdateCompanionBuilder =
    VariedadesTableCompanion Function({
      Value<int> id,
      Value<String> descripcion,
      Value<String?> fechaCreacion,
    });

class $$VariedadesTableTableFilterComposer
    extends Composer<_$AppDatabase, $VariedadesTableTable> {
  $$VariedadesTableTableFilterComposer({
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

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VariedadesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VariedadesTableTable> {
  $$VariedadesTableTableOrderingComposer({
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

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VariedadesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VariedadesTableTable> {
  $$VariedadesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fechaCreacion => $composableBuilder(
    column: $table.fechaCreacion,
    builder: (column) => column,
  );
}

class $$VariedadesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VariedadesTableTable,
          VariedadesTableData,
          $$VariedadesTableTableFilterComposer,
          $$VariedadesTableTableOrderingComposer,
          $$VariedadesTableTableAnnotationComposer,
          $$VariedadesTableTableCreateCompanionBuilder,
          $$VariedadesTableTableUpdateCompanionBuilder,
          (
            VariedadesTableData,
            BaseReferences<
              _$AppDatabase,
              $VariedadesTableTable,
              VariedadesTableData
            >,
          ),
          VariedadesTableData,
          PrefetchHooks Function()
        > {
  $$VariedadesTableTableTableManager(
    _$AppDatabase db,
    $VariedadesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VariedadesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VariedadesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VariedadesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<String?> fechaCreacion = const Value.absent(),
              }) => VariedadesTableCompanion(
                id: id,
                descripcion: descripcion,
                fechaCreacion: fechaCreacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String descripcion,
                Value<String?> fechaCreacion = const Value.absent(),
              }) => VariedadesTableCompanion.insert(
                id: id,
                descripcion: descripcion,
                fechaCreacion: fechaCreacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VariedadesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VariedadesTableTable,
      VariedadesTableData,
      $$VariedadesTableTableFilterComposer,
      $$VariedadesTableTableOrderingComposer,
      $$VariedadesTableTableAnnotationComposer,
      $$VariedadesTableTableCreateCompanionBuilder,
      $$VariedadesTableTableUpdateCompanionBuilder,
      (
        VariedadesTableData,
        BaseReferences<
          _$AppDatabase,
          $VariedadesTableTable,
          VariedadesTableData
        >,
      ),
      VariedadesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RegistrosLocalTableTableManager get registrosLocal =>
      $$RegistrosLocalTableTableManager(_db, _db.registrosLocal);
  $$PlantillasLocalTableTableManager get plantillasLocal =>
      $$PlantillasLocalTableTableManager(_db, _db.plantillasLocal);
  $$SyncCursorLocalTableTableManager get syncCursorLocal =>
      $$SyncCursorLocalTableTableManager(_db, _db.syncCursorLocal);
  $$CampaniasTableTableTableManager get campaniasTable =>
      $$CampaniasTableTableTableManager(_db, _db.campaniasTable);
  $$LotesTableTableTableManager get lotesTable =>
      $$LotesTableTableTableManager(_db, _db.lotesTable);
  $$LoteOrillasTableTableTableManager get loteOrillasTable =>
      $$LoteOrillasTableTableTableManager(_db, _db.loteOrillasTable);
  $$VariedadesTableTableTableManager get variedadesTable =>
      $$VariedadesTableTableTableManager(_db, _db.variedadesTable);
}
