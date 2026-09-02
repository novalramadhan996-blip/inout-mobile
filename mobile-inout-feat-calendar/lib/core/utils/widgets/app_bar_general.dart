import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';

class AppBarGeneral extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? action;
  final Color? backgroundColor, colorTitle, colorIcon;
  final TextStyle styleTitle;
  final Function? onBackPressed;
  final bool showBackButton;

  const AppBarGeneral({
    super.key,
    this.colorIcon,
    this.action,
    required this.title,
    required this.styleTitle,
    this.colorTitle,
    this.backgroundColor = AppColors.blackColor,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              onPressed: () => onBackPressed != null
                  ? onBackPressed!()
                  : context.router.popForced(),
              icon: Icon(Icons.arrow_back_ios, color: colorIcon),
            )
          : SizedBox.shrink(),
      titleSpacing: 0,
      backgroundColor: backgroundColor,
      title: Text(
        title,
        style: styleTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: action,
      shadowColor: Colors.black.withOpacity(0.9),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
