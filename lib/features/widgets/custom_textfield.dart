import 'package:flutter/material.dart';
import '../../constant/app_color.dart';

class CustomTextFormField extends StatelessWidget {
  String? hintText;
  String? labelText;
  Icon? prefixIcon;
  String? Function(String?)? validator;
  AutovalidateMode? autoValidate;
  void Function(String)? onChange;
  IconButton? suffix;
  TextInputType? fieldType;
  TextEditingController? textController;
  bool? ispassword = false;
  void Function()? onTap;
  bool? readOnly = false;
  double sizeHeight;
  String? initialValue;
  int? maxLines;
  void Function(String?)? onSaved;

  CustomTextFormField({
    super.key,
    this.hintText,
    this.textController,
    this.initialValue,
    this.onSaved,
    this.onChange,
    this.maxLines,
    this.suffix,
    this.validator,
    this.autoValidate,
    this.ispassword,
    this.fieldType,
    this.onTap,
    this.labelText,
    this.prefixIcon,
    this.readOnly,
    this.sizeHeight = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onTap: onTap,
      onSaved: onSaved,
      keyboardType: fieldType,
      validator: validator,
      autovalidateMode: autoValidate,
      onChanged: onChange,
      obscureText: ispassword ?? false,
      controller: textController,
      readOnly: readOnly ?? false,
      maxLines: maxLines ?? 4,
      minLines: 1,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14, vertical: sizeHeight),
        // suffix: suffix,
        suffixIcon: suffix,
        fillColor: Colors.white,
        filled: true,
        // contentPadding: const EdgeInsets.all(10),
        // border: InputBorder.none,
        // labelText: labelText,
        prefixIcon: prefixIcon,
        hintText: '$hintText',

        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColor.hintTextColor,
        ),
        // enabledBorder: OutlineInputBorder(
        //     borderSide: BorderSide(color: Colors.black.withOpacity(.3)),
        //     borderRadius: const BorderRadius.all(Radius.circular(10))),

        // // focused border style
        // focusedBorder: const OutlineInputBorder(
        //     borderSide: BorderSide(color: AppColor.buttonColor),
        //     borderRadius: BorderRadius.all(Radius.circular(10))),

        // errorBorder: const OutlineInputBorder(
        //     borderSide: BorderSide(color: Colors.red),
        //     borderRadius: BorderRadius.all(Radius.circular(10))),

        // disabledBorder: const OutlineInputBorder(
        //     borderSide: BorderSide(color: Colors.red),
        //     borderRadius: BorderRadius.all(Radius.circular(10))),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        // error focused border style
        // focusedErrorBorder: const OutlineInputBorder(
        // borderSide: BorderSide(color: Colors.red, ),
        // borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        // height: 1,
        // color: AppColor.hintTextColor,
      ),
    );
  }
}
