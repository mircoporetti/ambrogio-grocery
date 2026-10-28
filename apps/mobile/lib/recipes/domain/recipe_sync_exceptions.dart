sealed class RecipeSyncException implements Exception {
  const RecipeSyncException();
}

class SyncServerUnreachableException extends RecipeSyncException {
  const SyncServerUnreachableException();
}

class UnexpectedSyncResponseException extends RecipeSyncException {
  const UnexpectedSyncResponseException();
}

class PhotoRejectedException extends RecipeSyncException {
  const PhotoRejectedException();
}

class PhotoTransferFailedException extends RecipeSyncException {
  const PhotoTransferFailedException();
}
