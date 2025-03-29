part of 'home_cubit.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoadingPost extends HomeState {}

final class HomeLoadedPost extends HomeState {
  final List<PostModel> posts;

  HomeLoadedPost(this.posts);
}

final class HomeError extends HomeState {
  final String error;

  HomeError(this.error);
}

final class HomeLoadingMorePost extends HomeState {}

final class HomeLoadedMorePost extends HomeState {
  final List<PostModel> posts;

  HomeLoadedMorePost(this.posts);
}