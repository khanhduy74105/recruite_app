import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/ui/show_bottom.dart';
import 'package:flutter_application/core/ui/user_avatar.dart';
import 'package:flutter_application/features/home/repository/comment_repository.dart';
import 'package:flutter_application/features/home/widgets/post_photo_grid.dart';
import 'package:flutter_application/models/comment_model.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:flutter_application/core/utils/format.dart';

class CommentCardWidget extends StatelessWidget {
  const CommentCardWidget({super.key, required this.comment});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    UserModel user = comment.creator;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imagePath: user.avatarUrl,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " ${timeAgo(comment.createdAt!)}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  user.headline ?? "user",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: comment.content,
                      ),
                    ],
                  ),
                ),
                if (comment.imageUrls.isNotEmpty) ...[
                  PhotoGrid(
                      maxImages: 4,
                      imageUrls: comment.imageUrls
                          .map(
                            (e) => SupabaseService.getUrl(e),
                          )
                          .toList())
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Like",
                        style: TextStyle(
                            color:
                                comment.likes > 0 ? Colors.blue : Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Reply",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                if (comment.creator.id != SupabaseService.getCurrentUserId()) {
                  return;
                }
                showModalWrapper(context, [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("Edit"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text("Delete"),
                    onTap: () async {
                      await CommentRepository()
                          .deleteComment(comment.id)
                          .then((value) {
                        if (value) {
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),
                ]);
              },
              icon: const Icon(Icons.more_vert, color: Colors.grey)),
        ],
      ),
    );
  }
}
