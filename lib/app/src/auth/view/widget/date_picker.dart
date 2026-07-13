// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';
import 'package:intl/intl.dart';



class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? initialDate;
  final void Function(String)? onChanged;
  const DatePickerField({
    super.key,
    required this.controller,
    this.validator,
    this.initialDate,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Date of Birth',
            style: grey14RegularTextStyle,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialDate,
            readOnly: true,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: Colors.grey.shade600,
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down_rounded,
                size: 24,
                color: Colors.grey.shade600,
              ),
              hintText: "Select Date of Birth",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
            ),
            validator: validator,
            onTap: () => _selectDate(context),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(), // This restricts future date selection
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Verify selected date is not in future
      if (picked.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot select future dates'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      controller.text = DateFormat('yyyy/MM/dd').format(picked);
    }
  }
}
