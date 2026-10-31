import 'package:shelf/shelf.dart';

import 'json.dart';

Middleware cors(Set<String> allowedOrigins) =>
    (inner) => (request) async {
      final origin = request.headers['origin'];
      if (origin == null) return inner(request);
      if (!allowedOrigins.contains(origin)) {
        return errorResponse(403, 'origin_not_allowed');
      }
      final headers = {
        'access-control-allow-origin': origin,
        'access-control-allow-credentials': 'true',
        'vary': 'Origin',
      };
      if (request.method == 'OPTIONS') {
        return Response(
          204,
          headers: {
            ...headers,
            'access-control-allow-methods': 'GET, POST, PUT, DELETE',
            'access-control-allow-headers': 'authorization, content-type',
            'access-control-max-age': '600',
          },
        );
      }
      final response = await inner(request);
      return response.change(headers: headers);
    };

bool isFromWebApp(Request request) => request.headers.containsKey('origin');
