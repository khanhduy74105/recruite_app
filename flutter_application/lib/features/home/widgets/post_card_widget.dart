import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/utils/format.dart';
import 'package:flutter_application/features/home/widgets/post_photo_grid.dart';
import 'package:flutter_application/features/post/repository/post_repository.dart';
import 'package:flutter_application/features/post/widgets/job_card.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_application/models/user_models.dart';

class PostCardWidget extends StatefulWidget {
  const PostCardWidget({super.key, required this.postModel});

  final PostModel postModel;

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PostUserHeader(
          user: widget.postModel.creator!,
        ),
        PostContent(
          postModel: widget.postModel,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.thumb_up_alt_outlined),
              label: const Text("Thích"),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.comment_outlined),
              label: const Text("Bình luận"),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined),
              label: const Text("Đăng lại"),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send_outlined),
              label: const Text("Gửi"),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class PostContent extends StatelessWidget {
  const PostContent({
    super.key,
    required this.postModel,
  });

  final PostModel postModel;

  @override
  Widget build(BuildContext context) {
    List<String> imageLinks = postModel.imageLinks
                  .map(
                    (e) => SupabaseService.getUrl(e),
                  )
                  .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            postModel.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          if (postModel.job != null) JobCard(job: postModel.job!),
          const SizedBox(height: 10),
          PhotoGrid(
              maxImages: 4,
              imageUrls: imageLinks),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class PostUserHeader extends StatelessWidget {
  const PostUserHeader({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : const AssetImage("assets/profile.png"),
      ),
      title: Text(user.fullName),
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
        onPressed: () {},
      ),
    );
  }
}
