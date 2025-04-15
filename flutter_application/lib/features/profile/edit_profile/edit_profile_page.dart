import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/user_models.dart';
import 'edit_profile_cubit.dart';

class EditProfilePage extends StatelessWidget {
  final UserModel user;

  const EditProfilePage({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileCubit(),
      child: EditProfileContent(user: user),
    );
  }
}

class EditProfileContent extends StatefulWidget {
  final UserModel user;

  const EditProfileContent({required this.user, Key? key}) : super(key: key);

  @override
  _EditProfileContentState createState() => _EditProfileContentState();
}

class _EditProfileContentState extends State<EditProfileContent> {
  late TextEditingController _bioController;
  late TextEditingController _headlineController;
  late TextEditingController _locationController;
  late TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.user.bio);
    _headlineController = TextEditingController(text: widget.user.headline);
    _locationController = TextEditingController(text: widget.user.location);
    _avatarUrlController = TextEditingController(text: widget.user.avatarUrl);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _headlineController.dispose();
    _locationController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          BlocConsumer<EditProfileCubit, EditProfileState>(
            listener: (context, state) {
              if (state is EditProfileSuccess) {
                Navigator.pop(context);
              } else if (state is EditProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is EditProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  context.read<EditProfileCubit>().updateProfile(
                        userId: widget.user.id,
                        bio: _bioController.text,
                        headline: _headlineController.text,
                        location: _locationController.text,
                        avatarUrl: _avatarUrlController.text,
                      );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(
                labelText: 'Avatar URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _headlineController,
              decoration: const InputDecoration(
                labelText: 'Headline',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
