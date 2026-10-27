import 'json.dart';

abstract final class ErrorCodes {
  static const invalidRequest = 'invalid_request';
  static const unauthorized = 'unauthorized';
  static const invalidRecipe = 'invalid_recipe';
  static const tooManyChanges = 'too_many_changes';
}

class ErrorResponse {
  const ErrorResponse(this.error);

  factory ErrorResponse.fromJson(Object? json) =>
      ErrorResponse(readString(asObject(json), 'error'));

  final String error;

  Map<String, Object?> toJson() => {'error': error};
}
