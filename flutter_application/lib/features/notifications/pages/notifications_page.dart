import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/utils/format.dart';
import 'package:flutter_application/features/home/pages/post_detail.dart';
import 'package:flutter_application/features/post/repository/post_repository.dart';
import 'package:flutter_application/models/notification_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  final Map<String, Map<String, dynamic>> notificationTypes = const {
    'like': {
      'icon': Icons.fmd_good_sharp, // Use Material Icon
      'action': 'like',
    },
    'post': {
      'icon': Icons.post_add, // Use Material Icon
      'action': 'post',
    },
    'comment': {
      'icon': Icons.comment, // Use Material Icon
      'action': 'comment',
    },
    'network': {
      'icon': Icons.people, // Use Material Icon
      'action': 'network',
    },
  };

  Future<void> onTap(BuildContext context, String notificationId, String post_id) async {
    try {
      await Supabase.instance.client
          .from('notification')
          .update({'seen': true})
          .eq('id', notificationId);

      if (post_id.isEmpty) return;

      PostModel post = await PostRepository().fetchPostById(post_id);

      Navigator.push(context, MaterialPageRoute(
        builder: (context) => PostDetailPage(
          postModel: post,
        ),
      ));
    } catch (e) {
      print("Error marking notification as seen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: const Text("Notifications"),
        ),
        backgroundColor: Colors.white,
        drawerScrimColor: Colors.transparent,
        body: StreamBuilder(
            stream: Supabase.instance.client
                .from('notification')
                .stream(primaryKey: ['id'])
                .order('created_at', ascending: false)
                .asyncMap((response) async {
                  if (response.isEmpty) return List<NotificationModel>.empty();

                  final List<NotificationModel> notificationList = [];

                  String currentId = SupabaseService.getCurrentUserId();


                  for (var item in response) {
                    List<dynamic> relativeIds = jsonDecode(item['relative_ids'] ?? '[]');

                    if (!relativeIds.contains(currentId)) {
                      continue;
                    }
                    
                    NotificationModel notification =
                        NotificationModel.fromMap(item);
                    notificationList.add(notification);
                  }
                  return notificationList;
                }),
            builder: (context, snapshot) {
              return snapshot.data != null && snapshot.data!.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        NotificationModel notificationModel =
                            snapshot.data![index];
                        final type = notificationModel.type ?? 'post';
                        final notification = notificationTypes[type]!;
                        final isSeen = notificationModel.seen ?? false;
                        final timeAgoText = timeAgo(notificationModel.createdAt);
                        return NotificationCard(
                          icon: notification['icon'],
                          title: "Someone ${notification['action']} your post",
                          description:
                              "Hey you, someone ${notification['action']} your post, check now!",
                          timeAgo: timeAgoText,
                          isRead: !isSeen,
                          onTap: () {
                            onTap(
                              context,
                              notificationModel.id,
                              notificationModel.postId ?? '',
                            );
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No notifications available",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
            }));
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String timeAgo; // Add timeAgo text
  final bool isRead; // Add read state
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: isRead
          ? Colors.grey[200]
          : Colors.white, // Change card background color
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue, // Keep icon background consistent
          child: Icon(
            icon, // Use Icon widget
            size: 24,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Dim text if read
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Text(
              timeAgo,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
