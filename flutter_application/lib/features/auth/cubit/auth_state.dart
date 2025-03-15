part of "auth_cubit.dart";

sealed class AuthStates {}

final class AuthInitial extends AuthStates {}

final class AuthLoading extends AuthStates {}

final class AuthSignUp extends AuthStates {}

final class AuthLoggedIn extends AuthStates {
  final UserModel user;
  AuthLoggedIn(this.user);
}

final class AuthError extends AuthStates {
  final String error;
  AuthError(this.error);
}