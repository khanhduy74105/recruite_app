part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {
  final String message;

  const ProfileUpdating(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final ConnectionStatus? connectionStatus;

  const ProfileLoaded(this.user, [this.connectionStatus]);

  @override
  List<Object?> get props => [user, connectionStatus];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class AvatarUpdating extends ProfileState {}

class AvatarUpdated extends ProfileState {
  final String avatarUrl;

  const AvatarUpdated(this.avatarUrl);

  @override
  List<Object?> get props => [avatarUrl];
}

class AvatarUpdateError extends ProfileState {
  final String message;

  const AvatarUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

