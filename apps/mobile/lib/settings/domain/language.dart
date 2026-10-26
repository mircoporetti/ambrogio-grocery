enum Language {
  english('en'),
  italian('it');

  const Language(this.code);

  final String code;

  static Language? fromCode(String code) =>
      values.where((l) => l.code == code).firstOrNull;
}
