class DuplicateVoteException implements Exception {
  final String message;

  DuplicateVoteException(this.message);

  @override
  String toString() => message;
}
