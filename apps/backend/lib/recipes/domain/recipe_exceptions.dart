sealed class RecipeException implements Exception {
  const RecipeException();
}

class InvalidRecipeException extends RecipeException {
  const InvalidRecipeException(this.reason);

  final String reason;

  @override
  String toString() => 'InvalidRecipeException: $reason';
}

class TooManyChangesException extends RecipeException {
  const TooManyChangesException();
}
