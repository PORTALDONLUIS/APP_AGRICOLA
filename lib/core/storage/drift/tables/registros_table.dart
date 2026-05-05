import 'package:drift/drift.dart';

class RegistrosLocal extends Table {
  IntColumn get localId => integer().autoIncrement()();

  TextColumn get clientRecordId => text()();
  IntColumn get serverId => integer().nullable()();

  IntColumn get plantillaId => integer()();
  TextColumn get templateKey => text().withDefault(const Constant(''))();
  IntColumn get userId => integer()();

  // IntColumn get campaniaId => integer().nullable()();
  TextColumn get campaniaId => text().nullable()();
  IntColumn get loteId => integer().nullable()();

  RealColumn get lat => real().nullable()();
  RealColumn get lon => real().nullable()();

  TextColumn get estado => text().withDefault(const Constant('borrador'))();
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();
  TextColumn get syncError => text().nullable()();
  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();

  TextColumn get dataJson => text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
