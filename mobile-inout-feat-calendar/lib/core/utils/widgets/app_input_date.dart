import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/widgets/app_lable.dart';
import 'package:intl/intl.dart';

class AppInputDatePicker extends StatefulWidget {
  const AppInputDatePicker({
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
    this.firstDate,
    this.lastDate,
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
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<AppInputDatePicker> createState() => _AppInputDatePickerState();
}

class _AppInputDatePickerState extends State<AppInputDatePicker> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        final date = DateFormat('yyyy-MM-dd').format(picked);
        selectedDate = picked;
        widget.controller.text = date.toString();
        widget.onChanged?.call(date.toString());
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
            onTap: () => _selectDate(context),
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
