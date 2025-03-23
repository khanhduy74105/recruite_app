import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/colors.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/ui/button.dart';
import 'package:flutter_application/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_application/features/post/cubit/post_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  final List<File> selectedImages = []; // List to store selected images
  String content = '';
  String visibility = 'public';

  // Function to pick images
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void showModalChangeVisibility() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.3,
          child: Column(
            children: [
              ListTile(
                title: const Text("Public"),
                onTap: () {
                  setState(() {
                    visibility = 'public';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Connections"),
                onTap: () {
                  setState(() {
                    visibility = 'connection';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostSuccess) {
          setState(() {
            content = '';
            selectedImages.clear();
            visibility = 'public';
          });
          Navigator.pop(context); // Close the screen after success
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
              InkWell(
                onTap: () {
                  showModalChangeVisibility();
                },
                child: Row(
                  children: [
                    Text(visibility,
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                    Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
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
                    context.read<PostCubit>().createPost(
                        state.user.id,
                        content,
                        selectedImages,
                        visibility);
                  }
                },
              ),
            );
            }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  maxLines: null,
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
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
              if (selectedImages.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    icon: const Icon(Icons.image, size: 28, color: Colors.grey),
                    onPressed: _pickImage,
                  ),
                  _buildActionButton(Icons.calendar_today),
                  _buildActionButton(Icons.more_horiz),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildActionButton(IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Icon(icon, size: 28, color: Colors.grey),
  );
}
