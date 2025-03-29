import 'package:flutter/material.dart';

void showModalChangeVisibility(context, List<Widget> children) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      showDragHandle: true,
      builder: (context) {
        return Wrap(
          children: children,
        );
      },
    );
  }