class TokenNotFoundException implements Exception {
  final String message;

  TokenNotFoundException(this.message);

  @override
  String toString() => message;
}
