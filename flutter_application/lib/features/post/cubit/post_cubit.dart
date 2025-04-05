import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/features/post/repository/job_repository.dart';
import 'package:flutter_application/models/job_model.dart';
import 'package:flutter_application/models/post_model.dart';
import '../repository/post_repository.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(PostInitial());
  final PostRepository postRepository = PostRepository();
  final JobRepository jobRepository = JobRepository();

  Future<void> createPost(String creatorId, String content,
      List<File> imageLinks, String visibility, JobModel? job) async {
    emit(PostLoading());
    try {
      JobModel? insertedJob;
      if (job != null) {
        insertedJob = await jobRepository.createJob(job);
      }
      List<String> urls = await SupabaseService.upload(imageLinks);
      final success = await postRepository.createPost(
          creatorId: creatorId,
          content: content,
          imageLinks: urls,
          visibility: visibility,
          jobId: insertedJob?.id);
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

  Future<void> editPost(PostModel post, List<String> newImageLinks, List<File> imageLinks, JobModel? newJob) async {
    emit(PostLoading());
    try {
      final success = await postRepository.editPost(post, newImageLinks, imageLinks, newJob);
      if (success) {
        emit(PostSuccess());
      } else {
        emit(PostFailure('Failed to edit post'));
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    emit(PostLoading());
    try {
      final success = await postRepository.deletePost(postId);
      if (success) {
        emit(PostSuccess());
      } else {
        emit(PostFailure('Failed to delete post'));
      }
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }
}
