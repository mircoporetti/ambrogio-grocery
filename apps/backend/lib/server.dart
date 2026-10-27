import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'health/http/health_routes.dart';

Future<HttpServer> startServer({required int port, InternetAddress? address}) {
  final router = Router()..mount('/', HealthRoutes().router.call);
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);
  return shelf_io.serve(handler, address ?? InternetAddress.loopbackIPv4, port);
}
