import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/colors.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/ui/button.dart';
import 'package:flutter_application/core/ui/show_bottom.dart';
import 'package:flutter_application/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_application/features/post/cubit/post_cubit.dart';
import 'package:flutter_application/features/post/widgets/job_card.dart';
import 'package:flutter_application/models/job_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application/features/post/pages/job_create_page.dart';

void showCreatePostScreen(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const CreatePostScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  );
}

class VisibilitySelector extends StatelessWidget {
  final String visibility;
  final Function(String) onVisibilityChanged;

  const VisibilitySelector({
    Key? key,
    required this.visibility,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalChangeVisibility(context, [
          ListTile(
            title: const Text("Public"),
            onTap: () {
              onVisibilityChanged('public');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Connections"),
            onTap: () {
              onVisibilityChanged('connection');
              Navigator.pop(context);
            },
          ),
        ]);
      },
      child: Row(
        children: [
          Text(
            visibility == 'public' ? 'Public' : 'Connections',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final List<File> selectedImages = []; // List to store selected images
  String content = '';
  String visibility = 'public';
  TextEditingController contentController = TextEditingController();
  JobModel? jobModel;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFile = await picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      setState(() {
        for (var file in pickedFile) {
          selectedImages.add(File(file.path));
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostSuccess) {
          contentController.clear();
          setState(() {
            content = '';
            selectedImages.clear();
            visibility = 'public';
          });
          Navigator.pop(context);
        }

        if (state is PostFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/profile.png"),
              ),
              const SizedBox(width: 8),
              VisibilitySelector(
                visibility: visibility,
                onVisibilityChanged: (newVisibility) {
                  setState(() {
                    visibility = newVisibility;
                  });
                },
              ),
            ],
          ),
          actions: [
            BlocBuilder<AuthCubit, AuthStates>(builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CustomTextButton(
                  text: "Đăng",
                  activeColor: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () async {
                    if (state is AuthLoggedIn) {
                      context.read<PostCubit>().createPost(state.user.id,
                          content, selectedImages, visibility, jobModel);
                    }
                  },
                ),
              );
            }),
          ],
        ),
        body: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      controller: contentController,
                      decoration: const InputDecoration(
                        hintText: 'Bạn muốn nói về chủ đề gì?',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {
                          content = value;
                        });
                      },
                    ),
                  ),
                  if (jobModel != null)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                JobCreatePage(jobModel: jobModel!),
                          ),
                        );
                      },
                      child: JobCard(
                        job: jobModel!,
                        onClose: () {
                          setState(() {
                            jobModel = null;
                          });
                        },
                      ),
                    ),
                  if (selectedImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image,
                            size: 28, color: Colors.grey),
                        onPressed: _pickImage,
                      ),
                      IconButton(
                        icon: const Icon(Icons.badge_outlined,
                            size: 28, color: Colors.grey),
                        onPressed: () async {
                          JobModel? jm =
                              await Navigator.of(context).push<JobModel>(
                            MaterialPageRoute(
                              builder: (context) => const JobCreatePage(),
                            ),
                          );
                          setState(() {
                            jobModel = jm;
                          });
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
    );
  }
}
