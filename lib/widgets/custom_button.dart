import 'package:flutter/material.dart';
import 'package:message_app/constants/myColors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          myColors.themeColor,
        ),
        foregroundColor: MaterialStateProperty.all(
          myColors.themeColor,
        ),
      ),
    );
  }
}
