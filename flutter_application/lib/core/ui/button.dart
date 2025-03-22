import 'package:flutter/material.dart';

class CustomTextButton extends StatefulWidget {
  final String text;
  final IconData? leadingIcon;
  final Color activeColor;
  final Color textColor;
  final VoidCallback onPressed;

  const CustomTextButton({
    super.key,
    required this.text,
    this.leadingIcon,
    required this.activeColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  CustomTextButtonState createState() => CustomTextButtonState();
}

class CustomTextButtonState extends State<CustomTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onPressed,
      style: TextButton.styleFrom(
        backgroundColor: widget.activeColor,
        side: BorderSide(color: widget.textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leadingIcon != null)
            Icon(widget.leadingIcon, color: widget.textColor),
          if (widget.leadingIcon != null) const SizedBox(width: 8.0),
          Text(
            widget.text,
            style: TextStyle(color: widget.textColor),
          ),
        ],
      ),
    );
  }
}