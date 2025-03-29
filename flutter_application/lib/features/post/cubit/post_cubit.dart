import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/post/repository/job_repository.dart';
import 'package:flutter_application/models/job_model.dart';
import 'package:flutter_application/models/post_model.dart';
import '../repository/post_repository.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(PostInitial());
  final PostRepository postRepository = PostRepository();
  final JobRepository jobRepository = JobRepository();

  Future<void> createPost(String creatorId, String content, List<File> imageLinks, String visibility, JobModel? job) async {
    emit(PostLoading());
    try {
      JobModel? insertedJob;
      if (job != null) {
        insertedJob = await jobRepository.createJob(job);
      }
      final success = await postRepository.createPost(
        creatorId: creatorId,
        content: content,
        imageLinks: imageLinks,
        visibility: visibility,
        jobId: insertedJob?.id
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
