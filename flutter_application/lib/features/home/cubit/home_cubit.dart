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
}
