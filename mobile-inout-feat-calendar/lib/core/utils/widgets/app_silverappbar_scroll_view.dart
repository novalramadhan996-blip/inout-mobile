import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class CstmScrollView extends StatelessWidget {
  final SliverChildDelegate sliverChildDelegate;
  final String title;
  final IconData iconAction;
  final VoidCallback onPressedInIcon;
  const CstmScrollView(
      {super.key,
      required this.sliverChildDelegate,
      required this.iconAction,
      required this.onPressedInIcon,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          elevation: 0,
          centerTitle: true,
          pinned: true,
          titleTextStyle: AppStyle(color: AppColors.blackColor).headline2,
          expandedHeight: context.screenHeight / 4,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(2.0),
            child: Divider(
              color: AppColors.blackColor,
              thickness: 1,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 2,
            collapseMode: CollapseMode.pin,
            centerTitle: true,
            background: Image.asset(
              Assets.logo4Small,
              fit: BoxFit.contain,
            ),
            titlePadding: const EdgeInsets.only(left: 100, bottom: 10),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  title,
                  style: AppStyle(color: AppColors.blackColor).headline4,
                ),
                IconButton(
                    onPressed: onPressedInIcon,
                    icon: Icon(iconAction, color: AppColors.primaryColor))
              ],
            ),
          ),
        ),
        SliverList(delegate: sliverChildDelegate)
      ],
    );
  }
}
