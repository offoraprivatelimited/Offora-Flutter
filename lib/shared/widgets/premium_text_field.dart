import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PremiumTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  const PremiumTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the keyboard type to use.
    // If textInputAction is newline and maxLines > 1, ensure keyboardType is multiline
    // to avoid internal Flutter assertion failure.
    TextInputType effectiveKeyboardType = keyboardType;
    if (textInputAction == TextInputAction.newline &&
        maxLines > 1 &&
        keyboardType == TextInputType.text) {
      effectiveKeyboardType = TextInputType.multiline;
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: effectiveKeyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: AppColors.darkBlue,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(
          color: Color(0xFF666666),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFBBBBBB),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.darkBlue)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.darkBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
