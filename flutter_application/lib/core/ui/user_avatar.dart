import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? imagePath;
  const UserAvatar({
    super.key,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundImage: imagePath != null
            ? NetworkImage(imagePath!)
            : const AssetImage(
                "assets/profile.png",
              ),
      ),
    );
  }
}
