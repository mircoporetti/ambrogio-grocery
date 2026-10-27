class AccessToken {
  AccessToken({required this.value, required this.expiresAt});

  static const lifetime = Duration(minutes: 15);

  final String value;
  final DateTime expiresAt;
}
