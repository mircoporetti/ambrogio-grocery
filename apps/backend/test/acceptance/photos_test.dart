import 'package:test/test.dart';

import 'support/accounts_api.dart';
import 'support/api_client.dart';
import 'support/fixed_clock_adapter.dart';
import 'support/photos_api.dart';
import 'support/recipes_api.dart';

const tenMegabytes = 10 * 1024 * 1024;

void main() {
  late FixedClockAdapter clock;
  late AccountsApi accounts;
  late PhotosApi photos;
  late String ada;

  setUp(() async {
    // The photo storage checks signatures against the real time.
    clock = FixedClockAdapter(DateTime.now().toUtc());
    final api = await ApiClient.start(clock: clock);
    accounts = AccountsApi(api);
    photos = PhotosApi(api);
    ada = (await accounts.registerAndLogIn(
      'ada@example.com',
      'pw-ada-1',
    )).access;
  });

  test('asking for photo URLs needs a valid access token', () async {
    for (final token in [null, 'made-up-token']) {
      final upload = await photos.uploadUrl(token, photoA, contentLength: 10);
      final download = await photos.downloadUrl(token, photoA);

      for (final response in [upload, download]) {
        expect(response.status, 401, reason: '$token');
        expect(response['error'], 'unauthorized');
      }
    }
  });

  test('an uploaded photo downloads with the same bytes', () async {
    await photos.upload(ada, photoA, jpegBytes);

    expect(await photos.download(ada, photoA), jpegBytes);
  });

  test('a photo that was never uploaded is not found', () async {
    final response = await photos.downloadUrl(ada, photoA);

    expect(response.status, 404);
    expect(response['error'], 'photo_not_found');
  });

  test('each account only sees and changes its own photos', () async {
    final bob = (await accounts.registerAndLogIn(
      'bob@example.com',
      'pw-bob-1',
    )).access;
    await photos.upload(ada, photoA, jpegBytes);

    expect(await photos.download(bob, photoA), isNull);

    await photos.upload(bob, photoA, otherJpegBytes);

    expect(await photos.download(ada, photoA), jpegBytes);
    expect(await photos.download(bob, photoA), otherJpegBytes);
  });

  test('uploading the same photo again is harmless', () async {
    await photos.upload(ada, photoA, jpegBytes);
    await photos.upload(ada, photoA, jpegBytes);

    expect(await photos.download(ada, photoA), jpegBytes);
  });

  test('photos up to 10 MB can be uploaded', () async {
    final limit = await photos.uploadUrl(
      ada,
      photoA,
      contentLength: tenMegabytes,
    );
    final tooLarge = await photos.uploadUrl(
      ada,
      photoA,
      contentLength: tenMegabytes + 1,
    );

    expect(limit.status, 200);
    expect(tooLarge.status, 413);
    expect(tooLarge['error'], 'photo_too_large');
  });

  test('only images can be uploaded', () async {
    for (final type in ['image/jpeg', 'image/png', 'image/heic']) {
      final response = await photos.uploadUrl(
        ada,
        photoA,
        contentType: type,
        contentLength: 10,
      );
      expect(response.status, 200, reason: type);
    }

    final html = await photos.uploadUrl(
      ada,
      photoA,
      contentType: 'text/html',
      contentLength: 10,
    );

    expect(html.status, 415);
    expect(html['error'], 'unsupported_photo_type');
  });

  test('malformed requests are rejected', () async {
    final responses = [
      await photos.uploadUrl(ada, 'not-a-uuid', contentLength: 10),
      await photos.downloadUrl(ada, 'not-a-uuid'),
      await photos.uploadUrl(ada, photoA, contentLength: 0),
    ];

    for (final response in responses) {
      expect(response.status, 400);
      expect(response['error'], 'invalid_request');
    }
  });

  group('a signed upload', () {
    test('only accepts the size and type it was signed for', () async {
      final url = await photos.uploadUrl(
        ada,
        photoA,
        contentLength: jpegBytes.length,
      );

      final longer = await photos.send(url, body: [...jpegBytes, 0]);
      final png = await photos.send(
        url,
        body: jpegBytes,
        headers: {'content-type': 'image/png'},
      );

      expect(longer.statusCode, 403);
      expect(png.statusCode, 403);
      expect(await photos.download(ada, photoA), isNull);
    });

    test('only reaches the photo it was signed for', () async {
      final url = await photos.uploadUrl(
        ada,
        photoA,
        contentLength: jpegBytes.length,
      );
      final other = Uri.parse(
        url['url']! as String,
      ).toString().replaceFirst(photoA, photoB);

      final response = await photos.send(
        url,
        body: jpegBytes,
        url: Uri.parse(other),
      );

      expect(response.statusCode, 403);
      expect(await photos.download(ada, photoB), isNull);
    });

    test('expires after 15 minutes', () async {
      clock.advance(const Duration(minutes: -16));
      final url = await photos.uploadUrl(
        ada,
        photoA,
        contentLength: jpegBytes.length,
      );

      final response = await photos.send(url, body: jpegBytes);

      expect(
        DateTime.parse(url['expiresAt']! as String),
        clock.now().add(const Duration(minutes: 15)),
      );
      expect(response.statusCode, 403);
    });
  });

  group('a photo is deleted once no recipe uses it', () {
    late RecipesApi recipes;
    const pastaId = '0b9e4c1d-2f3a-4b5c-8d6e-7f8091a2b3c4';
    const saladId = '1c0f5d2e-3a4b-4c5d-9e6f-8091a2b3c4d5';
    final t1 = DateTime.utc(2026, 10, 20, 9);
    final t2 = t1.add(const Duration(minutes: 5));
    final t3 = t2.add(const Duration(minutes: 5));

    Map<String, Object?> withPhoto(Map<String, Object?> recipe, String? id) => {
      ...recipe,
      'photoId': id,
    };

    setUp(() async {
      recipes = RecipesApi(photos.api);
      await photos.upload(ada, photoA, jpegBytes);
      await recipes.push(ada, [
        upsert(pastaId, withPhoto(pasta, photoA), at: t1),
      ]);
    });

    test('when the recipe gets another photo', () async {
      await photos.upload(ada, photoB, otherJpegBytes);
      await recipes.push(ada, [
        upsert(pastaId, withPhoto(pasta, photoB), at: t2),
      ]);

      expect(await photos.download(ada, photoA), isNull);
      expect(await photos.download(ada, photoB), otherJpegBytes);
    });

    test('when the recipe loses its photo', () async {
      await recipes.push(ada, [
        upsert(pastaId, withPhoto(pasta, null), at: t2),
      ]);

      expect(await photos.download(ada, photoA), isNull);
    });

    test('when the recipe is deleted', () async {
      await recipes.push(ada, [deletion(pastaId, at: t2)]);

      expect(await photos.download(ada, photoA), isNull);
    });

    test('but not while another recipe still uses it', () async {
      await recipes.push(ada, [
        upsert(saladId, withPhoto(salad, photoA), at: t2),
      ]);
      await recipes.push(ada, [deletion(pastaId, at: t3)]);

      expect(await photos.download(ada, photoA), jpegBytes);
    });

    test('but not when the change loses to a newer one', () async {
      await recipes.push(ada, [
        upsert(pastaId, withPhoto(pasta, photoA), at: t3),
      ]);
      await recipes.push(ada, [deletion(pastaId, at: t2)]);

      expect(await photos.download(ada, photoA), jpegBytes);
    });

    test('but not when it belongs to another account', () async {
      final bob = (await accounts.registerAndLogIn(
        'bob@example.com',
        'pw-bob-1',
      )).access;
      await photos.upload(bob, photoA, otherJpegBytes);
      await recipes.push(bob, [
        upsert(pastaId, withPhoto(pasta, photoA), at: t1),
      ]);
      await recipes.push(bob, [deletion(pastaId, at: t2)]);

      expect(await photos.download(ada, photoA), jpegBytes);
    });
  });
}
