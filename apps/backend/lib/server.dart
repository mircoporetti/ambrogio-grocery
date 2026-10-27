import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'accounts/application/authenticate.dart';
import 'accounts/application/get_account.dart';
import 'accounts/application/log_in.dart';
import 'accounts/application/log_out.dart';
import 'accounts/application/refresh_session.dart';
import 'accounts/application/register_account.dart';
import 'accounts/data/drift_account_storage_adapter.dart';
import 'accounts/data/drift_session_storage_adapter.dart';
import 'accounts/domain/access_token_port.dart';
import 'accounts/domain/clock_port.dart';
import 'accounts/domain/password_hasher_port.dart';
import 'accounts/http/account_routes.dart';
import 'database/backend_database.dart';
import 'health/http/health_routes.dart';
import 'recipes/application/pull_recipe_changes.dart';
import 'recipes/application/push_recipe_changes.dart';
import 'recipes/data/drift_recipe_storage_adapter.dart';
import 'recipes/http/recipe_routes.dart';

Future<HttpServer> startServer({
  required int port,
  InternetAddress? address,
  required BackendDatabase database,
  required ClockPort clock,
  required PasswordHasherPort passwordHasher,
  required AccessTokenPort accessTokens,
}) {
  final accounts = DriftAccountStorageAdapter(database);
  final sessions = DriftSessionStorageAdapter(database);
  final recipes = DriftRecipeStorageAdapter(database);
  final authenticate = Authenticate(accessTokens, clock);
  final accountRoutes = AccountRoutes(
    RegisterAccount(accounts, passwordHasher),
    LogIn(accounts, sessions, passwordHasher, accessTokens, clock),
    RefreshSession(sessions, accessTokens, clock),
    LogOut(sessions),
    authenticate,
    GetAccount(accounts),
  );
  final recipeRoutes = RecipeRoutes(
    authenticate,
    PushRecipeChanges(recipes),
    PullRecipeChanges(recipes),
  );

  final router = Router()
    ..mount('/', HealthRoutes().router.call)
    ..mount('/', accountRoutes.router.call)
    ..mount('/', recipeRoutes.router.call);
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);
  return shelf_io.serve(handler, address ?? InternetAddress.loopbackIPv4, port);
}
