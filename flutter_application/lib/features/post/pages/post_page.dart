import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/colors.dart';
import 'package:flutter_application/core/ui/button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final List<File> _selectedImages = []; // List to store selected images

  // Function to pick images
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/profile.png"),
            ),
            InkWell(
              child: Row(
                children: [
                  Text("Bất cứ ai",
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                  Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CustomTextButton(
              text: "Đăng",
              activeColor: AppColors.primary,
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
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
                style: const TextStyle(fontSize: 16),
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Bạn muốn nói về chủ đề gì?',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
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
                            child: Icon(Icons.close, size: 16, color: Colors.white),
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
    );
  }
}

Widget _buildActionButton(IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: Icon(icon, size: 28, color: Colors.grey),
  );
}
