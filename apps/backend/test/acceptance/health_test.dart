import 'package:test/test.dart';

import 'support/api_client.dart';

void main() {
  test('the health check says the server is up', () async {
    final api = await ApiClient.start();

    final response = await api.get('/health');

    expect(response.status, 200);
    expect(response.json, {'status': 'ok'});
  });

  test('an unknown path is not found', () async {
    final api = await ApiClient.start();

    final response = await api.get('/nope');

    expect(response.status, 404);
  });
}
