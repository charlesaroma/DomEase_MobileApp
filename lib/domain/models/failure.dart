// ─── Failure ──────────────────────────────────────────────────────
// What a repository throws. Screens show [message]; they never see an HTTP
// error (docs/03-flutter-dos-and-donts.md).

sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No connection. Check your data or Wi-Fi and try again.');
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our side. Please try again.']);
}

/// A sign in that did not work: wrong password, wrong code, no account.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Premium and sharing need a household to attach to.
class NoHouseholdFailure extends Failure {
  const NoHouseholdFailure() : super('Set up your home first, then Premium can be added to it.');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'That could not be found.']);
}
