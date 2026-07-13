import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haqvox/app/constant/constant.dart';


class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hintText;
  final IconData icon;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField(
      {super.key,
      this.controller,
      required this.hintText,
      required this.icon,
      this.initialValue,
      this.validator,
      this.maxLength,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.suffixIcon,
      this.inputFormatters,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hintText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              hintText,
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
            initialValue: initialValue,
            onChanged: onChanged,
            validator: validator,
            maxLength: maxLength,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 20,
                color: Colors.grey.shade600,
              ),
              suffixIcon: suffixIcon,
              hintText: "Enter $hintText",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              counterText: "",
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
          ),
        ),
      ],
    );
  }
}
