class RecipeSyncLock {
  Future<void> _last = Future.value();

  Future<T> run<T>(Future<T> Function() task) {
    final result = _last.then((_) => task());
    _last = result.then((_) {}, onError: (_) {});
    return result;
  }
}
