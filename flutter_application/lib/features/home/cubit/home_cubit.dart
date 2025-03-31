import 'package:bloc/bloc.dart';
import 'package:flutter_application/features/post/repository/post_repository.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  void getPosts() async {
    try {
      emit(HomeLoadingPost());
      List<PostModel> posts = await PostRepository().fetchPosts();
      emit(HomeLoadedPost(posts));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void updatePost(PostModel updatedPost) {
    final currentState = state;
    if (currentState is HomeLoadedPost) {
      final updatedPosts = currentState.posts.map((post) {
        return post.id == updatedPost.id ? updatedPost : post;
      }).toList();

      emit(HomeLoadedPost(updatedPosts));
    }
  }

  void deletePost(String postId) {
    final currentState = state;
    if (currentState is HomeLoadedPost) {
      final updatedPosts = currentState.posts.where((post) => post.id != postId).toList();
      emit(HomeLoadedPost(updatedPosts));
    }
  }
}
