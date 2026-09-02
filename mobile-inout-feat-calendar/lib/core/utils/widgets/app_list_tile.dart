import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:flutter/material.dart';

class AppListTileWithDivider extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final VoidCallback? onTap;
  final double paddingTop;
  final Widget? leading, trailing, subtitle;
  const AppListTileWithDivider({
    super.key,
    this.onTap,
    required this.leading,
    this.titleStyle,
    this.paddingTop = 0,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop),
      child: Column(
        children: [
          ListTile(
            leading: leading,
            title: Text(title, style: titleStyle,),
            subtitle: subtitle,
            onTap: onTap,
            trailing: trailing,
          ),
          const Divider(
            height: 1.5,
            color: AppColors.greyColor,
          )
        ],
      ),
    );
  }
}

class AppListTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final TextStyle? style;
  final Widget? leading, trailing;
  final double paddingTop;
  const AppListTile({
    super.key,
    this.onTap,
    this.style,
    this.leading,
    this.paddingTop = 30,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: style,
        ),
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }
}
