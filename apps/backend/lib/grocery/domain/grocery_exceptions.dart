sealed class GroceryListException implements Exception {
  const GroceryListException();
}

class InvalidGroceryListException extends GroceryListException {
  const InvalidGroceryListException(this.reason);

  final String reason;

  @override
  String toString() => 'InvalidGroceryListException: $reason';
}

class TooManyGroceryListChangesException extends GroceryListException {
  const TooManyGroceryListChangesException();
}
