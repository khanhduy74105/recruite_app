part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class AvatarUpdating extends ProfileState {}

class AvatarUpdated extends ProfileState {
  final String newAvatarUrl;

  const AvatarUpdated(this.newAvatarUrl);

  @override
  List<Object?> get props => [newAvatarUrl];
}

class AvatarUpdateError extends ProfileState {
  final String message;

  const AvatarUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}