import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:flutter/material.dart';

class SwitchCtsm extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  const SwitchCtsm({super.key, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      inactiveTrackColor: Colors.grey[400],
      inactiveThumbColor: Colors.grey[200],
      activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
      activeColor: AppColors.primaryColor,
    );
  }
}
