import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/ui/show_bottom.dart';
import 'package:flutter_application/core/ui/user_avatar.dart';
import 'package:flutter_application/core/utils/format.dart';
import 'package:flutter_application/features/home/cubit/home_cubit.dart';
import 'package:flutter_application/features/home/pages/post_detail.dart';
import 'package:flutter_application/features/home/widgets/post_photo_grid.dart';
import 'package:flutter_application/features/post/cubit/post_cubit.dart';
import 'package:flutter_application/features/post/pages/post_page.dart';
import 'package:flutter_application/features/post/widgets/job_card.dart';
import 'package:flutter_application/models/comment_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../profile/pages/profile.dart';
import 'comment_card_widget.dart';

class PostCardWidget extends StatefulWidget {
  const PostCardWidget(
      {super.key,
      required this.postModel,
      this.isExpandedComments = false,
      this.isEditingMode = false});

  final PostModel postModel;
  final bool isExpandedComments;
  final bool isEditingMode;

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostUserHeader(
          postModel: widget.postModel,
        ),
        PostContent(
          postModel: widget.postModel,
          isExpandedComments: widget.isExpandedComments,
        ),
        if (!widget.isExpandedComments) const Divider(),
      ],
    );
  }
}

class PostAction extends StatelessWidget {
  const PostAction({
    super.key,
    required this.postModel,
    required this.isExpandedComments,
  });

  final PostModel postModel;
  final bool isExpandedComments;

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    String userId = SupabaseService.getCurrentUserId();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextButton.icon(
          onPressed: () {
            List<String> likes = postModel.likes.contains(userId)
                ? postModel.likes.where((element) => element != userId).toList()
                : [...postModel.likes, userId];

            context.read<HomeCubit>().updatePost(
                postModel.copyWith(
                  likes: likes,
                ),
                null,
                null,
                postModel.job);
          },
          icon: Icon(
            postModel.likes.contains(userId)
                ? Icons.thumb_up_alt
                : Icons.thumb_up_off_alt,
            size: 16,
            color: color,
          ),
          label: Text(
            "Like(${postModel.likes.length})",
            style: TextStyle(color: color),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            if (isExpandedComments) {
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostDetailPage(
                        postModel: postModel,
                      )),
            );
          },
          icon: Icon(Icons.comment_outlined, size: 16, color: color),
          label: Text(
            "Comment",
            style: TextStyle(color: color),
            softWrap: false,
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.send_outlined, size: 16, color: color),
          label: Text(
            "Sent",
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}

class PostContent extends StatelessWidget {
  const PostContent({
    super.key,
    required this.postModel,
    required this.isExpandedComments,
  });

  final PostModel postModel;
  final bool isExpandedComments;

  @override
  Widget build(BuildContext context) {
    List<String> imageLinks = postModel.imageLinks
        .map(
          (e) => SupabaseService.getUrl(e),
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (postModel.content.isNotEmpty)
            Text(
              postModel.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (postModel.job != null) ...[
            const SizedBox(height: 10),
            JobCard(job: postModel.job!)
          ],
          if (postModel.imageLinks.isNotEmpty) ...[
            const SizedBox(height: 10),
            PhotoGrid(maxImages: 4, imageUrls: imageLinks)
          ],
          PostAction(
            postModel: postModel,
            isExpandedComments: isExpandedComments,
          ),
        ],
      ),
    );
  }
}

class PostUserHeader extends StatelessWidget {
  const PostUserHeader({
    super.key,
    required this.postModel,
  });

  final PostModel postModel;

  @override
  Widget build(BuildContext context) {
    UserModel user = postModel.creator!;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16),
      leading: UserAvatar(
        imagePath: user.avatarUrl,
        onTap: () {
          goProfile(context, user);
        },
      ),
      title: GestureDetector(
        onTap: () {
          goProfile(context, user);
        },
          child: Text(user.fullName)),
      subtitle: Row(
        children: [
          Text(user.role != null ? user.role!.name : 'user'),
          const SizedBox(width: 5),
          const Icon(Icons.circle, size: 5),
          const SizedBox(width: 5),
          Text(timeAgo(user.createdAt!)),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          if (user.id != SupabaseService.getCurrentUserId()) return;
          showModalWrapper(context, [
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return ListTile(
                  title: const Text("Delete"),
                  onTap: () async {
                    context.read<HomeCubit>().deletePost(postModel.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
            BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                return ListTile(
                  title: const Text("Edit"),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatePostScreen(
                                postModel: postModel,
                              )),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ]);
        },
      ),
    );
  }

  void goProfile(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(
                userId: user.id,
              )),
    );
  }
}

class PostComment extends StatefulWidget {
  const PostComment({
    super.key,
    required this.comments,
    this.onEditComment,
    this.onReplyComment,
  });

  final List<CommentModel> comments;
  final Function(CommentModel comment, {bool isRemove})? onEditComment;
  final Function(CommentModel c)? onReplyComment;

  @override
  State<PostComment> createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "${widget.comments.length} comments",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.comments.length,
            itemBuilder: (context, index) {
              CommentModel comment = widget.comments[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommentCardWidget(
                    comment: comment,
                    onEditComment: widget.onEditComment,
                    onReplyComment: widget.onReplyComment,
                  ),
                  const SizedBox(height: 10),
                  if (comment.replies.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 24.0),
                      child: Column(
                        children: comment.replies
                            .map((reply) => CommentCardWidget(
                                  comment: reply,
                                  parentComment: comment,
                                  onEditComment: widget.onEditComment,
                                  onReplyComment: widget.onReplyComment,
                                ))
                            .toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
