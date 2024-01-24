class InvalidLoginException implements Exception {
  final String message;

  InvalidLoginException(this.message);

  @override
  String toString() => message;
}
