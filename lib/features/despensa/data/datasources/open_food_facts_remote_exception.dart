class OpenFoodFactsRemoteException implements Exception {
  const OpenFoodFactsRemoteException({this.statusCode, required this.message});

  final int? statusCode;
  final String message;

  @override
  String toString() {
    if (statusCode != null) {
      return 'OpenFoodFactsRemoteException(statusCode: $statusCode, message: $message)';
    }
    return 'OpenFoodFactsRemoteException(message: $message)';
  }
}
