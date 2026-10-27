import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

import '../../database/backend_database.dart';
import '../domain/account_id.dart';
import '../domain/refresh_token.dart';
import '../domain/session.dart';
import '../domain/session_id.dart';
import '../domain/session_storage_port.dart';

class DriftSessionStorageAdapter implements SessionStoragePort {
  DriftSessionStorageAdapter(this._db);

  final BackendDatabase _db;

  // Only the hash is stored: a leaked database doesn't give working tokens.
  // A fast hash is enough because tokens are long and random, unlike
  // passwords.
  String _hash(String token) => sha256.convert(utf8.encode(token)).toString();

  @override
  Future<void> save(Session session) => _db
      .into(_db.sessions)
      .insert(
        SessionsCompanion.insert(
          id: UuidValue.fromString(session.id.value),
          accountId: UuidValue.fromString(session.accountId.value),
        ),
      );

  @override
  Future<void> saveRefreshToken(RefreshToken token) => _db
      .into(_db.refreshTokens)
      .insert(
        RefreshTokensCompanion.insert(
          tokenHash: _hash(token.value),
          sessionId: UuidValue.fromString(token.session.id.value),
          expiresAt: PgDateTime(token.expiresAt.toUtc()),
        ),
      );

  @override
  Future<RefreshToken?> findRefreshToken(String value) async {
    final query = _db.select(_db.refreshTokens).join([
      innerJoin(
        _db.sessions,
        _db.sessions.id.equalsExp(_db.refreshTokens.sessionId),
      ),
    ])..where(_db.refreshTokens.tokenHash.equals(_hash(value)));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final token = row.readTable(_db.refreshTokens);
    final session = row.readTable(_db.sessions);
    return RefreshToken(
      value: value,
      session: Session(
        id: SessionId(session.id.uuid),
        accountId: AccountId(session.accountId.uuid),
      ),
      expiresAt: token.expiresAt.dateTime.toUtc(),
      used: token.used,
    );
  }

  @override
  Future<bool> markUsed(RefreshToken token) async {
    final updated =
        await (_db.update(_db.refreshTokens)..where(
              (t) => t.tokenHash.equals(_hash(token.value)) & t.used.not(),
            ))
            .write(const RefreshTokensCompanion(used: Value(true)));
    return updated == 1;
  }

  @override
  Future<void> delete(SessionId id) => (_db.delete(
    _db.sessions,
  )..where((s) => s.id.equals(UuidValue.fromString(id.value)))).go();
}
