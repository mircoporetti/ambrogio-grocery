sealed class RecipeSyncException implements Exception {
  const RecipeSyncException();
}

class SyncServerUnreachableException extends RecipeSyncException {
  const SyncServerUnreachableException();
}

class UnexpectedSyncResponseException extends RecipeSyncException {
  const UnexpectedSyncResponseException();
}
