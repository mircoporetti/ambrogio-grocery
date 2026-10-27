import 'account_exceptions.dart';

class Email {
  Email(String value) : value = value.trim().toLowerCase() {
    if (this.value.length > 254 || !_pattern.hasMatch(this.value)) {
      throw const InvalidEmailException();
    }
  }

  static final _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final String value;

  @override
  bool operator ==(Object other) => other is Email && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Email($value)';
}
