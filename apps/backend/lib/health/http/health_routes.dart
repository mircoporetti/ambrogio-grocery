import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class HealthRoutes {
  Router get router => Router()..get('/health', _health);

  Response _health(Request request) => Response.ok(
    jsonEncode({'status': 'ok'}),
    headers: {'content-type': 'application/json'},
  );
}
