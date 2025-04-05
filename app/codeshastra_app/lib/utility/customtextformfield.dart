// import 'package:ai_farmer_app/Constants/app_colors.dart';
import 'package:codeshastra_app/Constants/app_colors.dart';
import 'package:flutter/material.dart';
// import 'package:local/Constants/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  TextEditingController controller;
  // String labelText;
  String hintText;
  TextInputType keyboardType;
  String errortext;
  bool isPassword;

  CustomTextFormField({
    required this.controller,
    // required this.labelText,
    required this.errortext,
    this.hintText = '',
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(255, 185, 246, 213),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 2, color: AppColors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 2, color: Colors.transparent),
        ),
        // labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errortext;
        }
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final Color hintColor;
  final Color labelColor;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final VoidCallback? onFocusChanged;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Icon? suffixIcon;
  final TextInputType? keyboardtype;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.hintColor = AppColors.grey,
    this.labelColor = AppColors.grey,
    this.maxLines,
    this.maxLength,
    this.focusNode,
    this.onFocusChanged,
    this.onChanged,
    this.onTap,
    this.suffixIcon,
    this.keyboardtype,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SizedBox(
      height: 0.09 * h, // Increase height
      width: double.infinity,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        cursorColor: AppColors.black,
        keyboardType: keyboardtype,
        decoration: InputDecoration(
          suffix: Icon(Icons.person),
          labelText: labelText,
          labelStyle: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w600,
            fontFamily: "popR",
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintColor,
            fontWeight: FontWeight.w600,
            fontFamily: "popR",
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(0, 0, 0, 0.6)),
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon:
              suffixIcon != null
                  ? GestureDetector(onTap: onTap, child: suffixIcon)
                  : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 10.0,
          ), // Add content padding
        ),
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500, // Adjust font size as needed
        ),
      ),
    );
  }
}
