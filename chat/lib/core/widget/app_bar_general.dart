// import 'package:auto_route/auto_route.dart';
import 'package:chat/ui/loading_screen.dart';
import 'package:flutter/material.dart';

class AppBarGeneral extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? action;
  final Color? backgroundColor, colorTitle, colorIcon;
  final Function? onBackPressed;

  const AppBarGeneral({
    super.key,
    this.colorIcon,
    this.action,
    required this.title,
    this.colorTitle,
    this.backgroundColor = Colors.black,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        onPressed: () => onBackPressed != null
            ? onBackPressed!()
            : Navigator.of(context).maybePop(),
        icon: Icon(Icons.arrow_back_ios, color: colorIcon),
      ),
      titleSpacing: 0,
      backgroundColor: backgroundColor,
      title: Text(title),
      actions: action,
      shadowColor: Colors.black.withOpacity(0.9),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
