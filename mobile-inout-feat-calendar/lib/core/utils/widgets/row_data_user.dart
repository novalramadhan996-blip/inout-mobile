import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:flutter/material.dart';

class UserDataRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxlines;

  const UserDataRow({
    Key? key,
    required this.label,
    required this.value,
    this.maxlines = 1
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  value,
                  maxLines: maxlines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Divider(
            height: 1,
            color: AppColors.greyButtonColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
