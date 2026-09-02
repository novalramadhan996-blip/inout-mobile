import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.label = "",
    this.onChanged,
    this.inputType = TextInputType.text,
    this.readOnly = false,
    this.showText = true,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.inputFormatters,
    this.elevation = 0,
    this.paddingTop = 8.0,
    this.paddingBottom = 8.0,
    this.isRequired = false,
    this.prefix,
  });

  final TextEditingController controller;
  final String hintText;
  final String label;
  final Widget? suffixIcon, prefixIcon;
  final bool showText;
  final bool readOnly;
  final Function(String)? onChanged;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final double elevation, paddingTop, paddingBottom;
  final bool isRequired;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label != ""
              ? AppLabel(label: label, isRequired: isRequired)
              : Container(),
          Material(
            elevation: elevation,
            shadowColor: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            type: MaterialType.transparency,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: inputType,
              controller: controller,
              readOnly: readOnly,
              obscureText: !showText,
              maxLines: maxLines,
              maxLength: maxLength,
              autofocus: autofocus,
              inputFormatters: inputFormatters,
              style: const TextStyle(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                prefix: prefix,
                prefixIconColor: AppColors.secondaryColor,
                prefixIcon: prefixIcon,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                prefixStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryColor,
                ),
                fillColor: readOnly
                    ? const Color(0xffE2E8F0)
                    : AppColors.whiteColor,
                filled: true,
                suffixIcon: suffixIcon,
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.secondaryColor),
                labelStyle: const TextStyle(color: AppColors.whiteColor),
                contentPadding: const EdgeInsets.all(12),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.redColors),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                errorStyle: const TextStyle(
                  fontSize: 10,
                  height: 0.3,
                  color: AppColors.redColors,
                ),
              ),
              validator: validator,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
