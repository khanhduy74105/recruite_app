import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? imagePath;
  final double? size; // Optional size parameter
  const UserAvatar({
    super.key,
    this.imagePath,
    this.onTap,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: size != null ? size! / 2 : null, // Set radius based on size
        backgroundImage: imagePath != null
            ? NetworkImage(imagePath!)
            : const AssetImage(
                "assets/profile.png",
              ) as ImageProvider,
      ),
    );
  }
}
