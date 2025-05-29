import 'dart:io'; // Add this for File handling
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/ui/user_avatar.dart';
import 'package:flutter_application/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_application/features/home/repository/comment_repository.dart';
import 'package:flutter_application/features/home/widgets/post_card_widget.dart';
import 'package:flutter_application/models/comment_model.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel postModel;

  const PostDetailPage({Key? key, required this.postModel}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  CommentRepository commentRepository = CommentRepository();
  TextEditingController commentController = TextEditingController();
  List<File> selectedImages = [];
  String commentText = '';
  String? replyComment;
  UserModel? mentionUser;
  List<CommentModel>? comments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchComments();
    });
  }

  void _fetchComments() async {
    isLoading = true;
    setState(() {
      mentionUser = null;
      replyComment = null;
    });
    commentRepository.fetchComments(widget.postModel.id).then(
      (value) {
        comments = value;
        isLoading = false;
        setState(() {});
      },
    ).catchError((error) {
      print('Error fetching comments: $error');
      isLoading = false;
      setState(() {});
    });
  }

  void _pickImages() async {
    final pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        selectedImages = pickedImages.map((e) => File(e.path)).toList();
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void editComment(CommentModel comment, {bool isRemove = false}) {
    setState(() {
      comments = comments?.map((c) {
        return c.id == comment.id ? isRemove == true ? null : comment : c;
      }).toList().where((c) => c != null).cast<CommentModel>().toList();
    });
  }

  void onReplyComment(CommentModel comment) {
    if (comment.parentCommentId != null) {
      setState(() {
        replyComment = comment.parentCommentId;
        mentionUser = comment.mentionUser;
      });
    } else {
      setState(() {
        replyComment = comment.id;
        mentionUser = comment.creator;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: max(MediaQuery.of(context).viewInsets.bottom, 140)),
                child: Column(
                  children: [
                    PostCardWidget(
                      postModel: widget.postModel,
                      isExpandedComments: true,
                    ),
                    PostComment(
                      comments: comments ?? [],
                      onEditComment: editComment,
                      onReplyComment: onReplyComment,
                    ),
                  ],
                )),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BlocBuilder<AuthCubit, AuthStates>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.black38, width: 1.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedImages.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                List.generate(selectedImages.length, (index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Image.file(
                                      selectedImages[index],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: const CircleAvatar(
                                        radius: 10,
                                        child: Icon(
                                          Icons.close,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          UserAvatar(
                            imagePath: widget.postModel.creator?.avatarUrl,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              maxLines: 1,
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Leave a comment...',
                                hintStyle: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.0,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 0.0,
                                ),
                                prefixIcon: mentionUser != null
                                    ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                        child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '@${mentionUser?.fullName}',
                                                  style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        mentionUser = null;
                                                      });
                                                    },
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                    )),
                                              ],
                                            ),
                                      ),
                                    )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.image, color: Colors.grey),
                                onPressed: _pickImages,
                              ),
                            ],
                          ),
                          BlocBuilder<AuthCubit, AuthStates>(
                            builder: (context, state) {
                              return TextButton(
                                onPressed: () async {
                                  if (state is! AuthLoggedIn) {
                                    return;
                                  }
                                  UserModel currentUser =
                                      (state as AuthLoggedIn).user;
                                  String postId = widget.postModel.id;
                                  String content =
                                      commentController.text.trim();
                                  List<String> imageUrls =
                                      await SupabaseService.upload(
                                          selectedImages);
                                  CommentModel comment = CommentModel(
                                    id: '',
                                    postId: postId,
                                    creator: currentUser,
                                    content: content,
                                    imageUrls: imageUrls,
                                    parentCommentId: replyComment,
                                  );

                                  comment.mentionUser = mentionUser;
                                  comment.parentCommentId = replyComment;

                                  CommentModel inserted =
                                      await commentRepository.createComment(
                                    comment,
                                  );

                                  if (inserted.id.isNotEmpty) {
                                    commentController.clear();
                                    selectedImages.clear();
                                    _fetchComments();
                                  }
                                },
                                child: const Text(
                                  'Sent',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
