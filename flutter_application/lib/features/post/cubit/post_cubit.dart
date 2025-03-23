import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../repository/post_repository.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(PostInitial());
  final PostRepository postRepository = PostRepository();

  Future<void> createPost(String creatorId, String content, List<File> imageLinks, String visibility) async {
    emit(PostLoading());
    try {
      final success = await postRepository.createPost(
        creatorId: creatorId,
        content: content,
        imageLinks: imageLinks,
        visibility: visibility,
      );
      if (success) {
        emit(PostSuccess());
      } else {
        emit(PostFailure('Failed to create post'));
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  Future<void> fetchPosts() async {
    emit(PostLoading());
    try {
      final posts = await postRepository.fetchPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }
}
