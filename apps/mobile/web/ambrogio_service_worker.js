'use strict';

const VERSION = '__AMBROGIO_VERSION__';
const CACHE = `ambrogio-${VERSION}`;

const CORE = [
  'index.html',
  'flutter_bootstrap.js',
  'register_service_worker.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'drift_worker.js',
  'sqlite3.wasm',
];

const scoped = (path) => new URL(path, self.registration.scope).href;

const isAppFile = (url) => {
  const { origin, pathname } = new URL(url);
  return origin === self.location.origin && pathname !== self.location.pathname;
};

async function store(cache, url, { required }) {
  const response = await fetch(url, { cache: 'no-cache' });
  if (response.ok) return cache.put(url, response);
  if (required) throw new Error(`${url}: ${response.status}`);
}

// Downloads the new version completely before using it: files of two
// versions never mix, and a failed download keeps the current one.
self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const previous = new Set();
      for (const name of await caches.keys()) {
        if (!name.startsWith('ambrogio-') || name === CACHE) continue;
        for (const request of await (await caches.open(name)).keys()) {
          previous.add(request.url);
        }
      }
      const core = CORE.map(scoped);
      const cache = await caches.open(CACHE);
      await Promise.all([
        ...core.map((url) => store(cache, url, { required: true })),
        ...[...previous]
          .filter((url) => !core.includes(url) && isAppFile(url))
          .map((url) => store(cache, url, { required: false })),
      ]);
    })(),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      for (const name of await caches.keys()) {
        if (name.startsWith('ambrogio-') && name !== CACHE) {
          await caches.delete(name);
        }
      }
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('message', (event) => {
  const { type, urls } = event.data ?? {};
  if (type === 'skipWaiting') self.skipWaiting();
  if (type === 'cache') {
    event.waitUntil(
      (async () => {
        const cache = await caches.open(CACHE);
        for (const url of urls ?? []) {
          if (!isAppFile(url) || (await cache.match(url))) continue;
          await store(cache, url, { required: false }).catch(() => {});
        }
      })(),
    );
  }
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET' || !isAppFile(request.url)) return;
  const navigation = request.mode === 'navigate';
  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE);
      const cached = navigation
        ? await cache.match(scoped('index.html'))
        : await cache.match(request);
      if (cached) return cached;
      const response = await fetch(request);
      if (response.ok && !navigation) {
        await cache.put(request, response.clone());
      }
      return response;
    })(),
  );
});
