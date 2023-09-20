import 'package:flutter/material.dart';
import 'package:memoir_app_bloc/features/widgets/custom_button.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog(
      {super.key, required this.title, required this.confirmFunction});
  final String title;
  final Widget confirmFunction;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16),
      title: const Text('Are you sure to delete all favorite note',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
      children: [
        confirmFunction,
        CustomButton(
          textButton: 'Cancel',
          colorButton: Colors.grey[300],
          colorText: Colors.black,
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
