import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';
import 'package:intl/intl.dart';

class AppInputTimePicker extends StatefulWidget {
  const AppInputTimePicker({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.label = "",
    required this.onChanged,
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
  State<AppInputTimePicker> createState() => _AppInputTimePickerState();
}

class _AppInputTimePickerState extends State<AppInputTimePicker> {
  TimeOfDay? selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        final time = picked.format(context);
        widget.controller.text = time;
        widget.onChanged?.call(time);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label.isNotEmpty
              ? AppLabel(label: widget.label, isRequired: widget.isRequired)
              : SizedBox(height: 22),
          GestureDetector(
            onTap: () => _selectTime(context),
            child: AbsorbPointer(
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: widget.inputType,
                controller: widget.controller,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                autofocus: widget.autofocus,
                inputFormatters: widget.inputFormatters,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  prefix: widget.prefix,
                  prefixIconColor: AppColors.secondaryColor,
                  prefixIcon: widget.prefixIcon,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  prefixStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryColor,
                  ),
                  fillColor: AppColors.whiteColor,
                  filled: true,
                  suffixIcon: widget.suffixIcon,
                  hintText: widget.hintText,
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
                validator: widget.validator,
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
