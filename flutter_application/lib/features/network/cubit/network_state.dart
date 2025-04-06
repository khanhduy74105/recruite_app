part of 'network_cubit.dart';

@immutable
sealed class NetworkState {}

final class NetworkInitial extends NetworkState {}

final class NetworkLoading extends NetworkState {}

final class NetworkLoaded extends NetworkState {
  final List<UserModel> usersNotFriends;
  final List<UserModel> usersFriends;

  final List<UserConnection> connections;

  NetworkLoaded(this.usersNotFriends, this.connections, this.usersFriends);
}


final class NetworkError extends NetworkState {
  final String error;

  NetworkError(this.error);
}
