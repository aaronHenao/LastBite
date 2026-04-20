class RecetasRemoteException implements Exception {
  const RecetasRemoteException({
    this.statusCode,
    required this.message,
  });

  final int? statusCode;
  final String message;

  @override
  String toString() {
    if (statusCode != null) {
      return 'RecetasRemoteException(statusCode: $statusCode, message: $message)';
    }
    return 'RecetasRemoteException(message: $message)';
  }
}
