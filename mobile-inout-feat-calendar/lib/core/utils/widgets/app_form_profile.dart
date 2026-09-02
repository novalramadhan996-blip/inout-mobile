import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/widgets/app_input.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';
import 'package:flutter/material.dart';

class AppFormProfile extends StatelessWidget {
  final String label, hinttext;
  final TextEditingController controller;
  final Function(String) onchanged;
  final bool showText;
  final bool readOnly;
  final bool isRequired;
  final String? Function(String?)? validator;

  const AppFormProfile({
    required this.label,
    required this.hinttext,
    required this.controller,
    required this.onchanged,
    this.showText = true,
    this.readOnly = false,
    this.isRequired = true,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppLabel(
          label: label,
          isRequired: isRequired,
        ),
        AppInput(
          showText: showText,
          controller: controller,
          hintText: hinttext,
          onChanged: onchanged,
          readOnly: readOnly,
          validator: validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required!';
                }
                return null;
              },
        ).bottomPadded(5),
      ],
    );
  }
}
