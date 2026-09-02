import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:flutter/material.dart';

class AppFilterBar extends StatelessWidget {
  const AppFilterBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.filter_list_rounded,
            size: 30,
            color: AppColors.primaryColor,
          ),
        ),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
              vertical: 3,
            ),
            child: TextField(
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[500],
              ),
              decoration: const InputDecoration(
                  hintText: "Type your search here...",
                  border: InputBorder.none),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.search,
            size: 30,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
