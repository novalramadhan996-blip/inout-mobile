import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/widgets/app_list_tile.dart';
import 'package:flutter/material.dart';

class BiodataUser extends StatelessWidget {
  final String field, value;
  final IconButton? icontrailing;
  final double height, marginRight;
  const BiodataUser({
    super.key,
    required this.field,
    required this.value,
    this.icontrailing,
    this.marginRight = 10,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AppListTileWithDivider(
        leading: Container(
          margin: EdgeInsets.only(right: marginRight),
          child: Text(
            field,
            style: AppStyle(color: AppColors.blackColor).headline4,
          ),
        ),
        title: value,
        trailing: icontrailing,
      ),
    );
  }
}
