import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, this.title = 'Movie Night'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium, // Use app theme for consistency
      ),
      centerTitle: true, // Center the title for a modern look
      backgroundColor:
          Theme.of(context).colorScheme.primary, // Consistent color
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
