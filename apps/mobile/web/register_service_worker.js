'use strict';

(() => {
  if (!('serviceWorker' in navigator)) return;

  const version = '__AMBROGIO_VERSION__';
  if (version.startsWith('__')) {
    navigator.serviceWorker
      .getRegistrations()
      .then((registrations) => registrations.forEach((r) => r.unregister()));
    caches
      ?.keys()
      .then((names) =>
        names
          .filter((name) => name.startsWith('ambrogio-'))
          .forEach((name) => caches.delete(name)),
      );
    return;
  }

  navigator.storage?.persist?.().catch(() => {});

  let updating = false;
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    if (updating) location.reload();
  });

  navigator.serviceWorker
    .register('ambrogio_service_worker.js')
    .then((registration) => {
      if (registration.waiting && navigator.serviceWorker.controller) {
        updating = true;
        registration.waiting.postMessage({ type: 'skipWaiting' });
      }
      document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible') {
          registration.update().catch(() => {});
        }
      });
    })
    .catch((error) => console.warn('Offline support unavailable:', error));

  window.addEventListener(
    'flutter-first-frame',
    async () => {
      const registration = await navigator.serviceWorker.ready;
      const urls = performance
        .getEntriesByType('resource')
        .map((entry) => entry.name)
        .filter((url) => new URL(url).origin === location.origin);
      registration.active?.postMessage({ type: 'cache', urls });
    },
    { once: true },
  );
})();
