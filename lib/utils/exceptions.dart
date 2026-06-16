class KoverException implements Exception {
  final String message;
  final int? statusCode;

  const KoverException(this.message, {this.statusCode});

  @override
  String toString() => 'KoverException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

class SyncException extends KoverException {
  const SyncException(super.message, {super.statusCode});
}

class CredentialsException extends KoverException {
  const CredentialsException(super.message);
}

class InvalidUrlException extends KoverException {
  const InvalidUrlException(super.message);
}

class ApiErrorException extends KoverException {
  const ApiErrorException(super.message, {super.statusCode});
}
