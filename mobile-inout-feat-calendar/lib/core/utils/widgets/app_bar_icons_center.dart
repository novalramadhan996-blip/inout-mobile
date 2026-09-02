import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:flutter/material.dart';

class AppBarIconCenter extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;

  const AppBarIconCenter({
    super.key,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      backgroundColor: backgroundColor,
      title: Image.asset(
        Assets.logoPng,
        width: 200,
      ),
      shadowColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
