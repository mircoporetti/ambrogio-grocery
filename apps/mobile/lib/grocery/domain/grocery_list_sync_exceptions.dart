sealed class GroceryListSyncException implements Exception {
  const GroceryListSyncException();
}

class GroceryListServerUnreachableException extends GroceryListSyncException {
  const GroceryListServerUnreachableException();
}

class UnexpectedGroceryListResponseException extends GroceryListSyncException {
  const UnexpectedGroceryListResponseException();
}
