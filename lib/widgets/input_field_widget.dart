import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';

class InputField extends StatefulWidget {
  late IconData icon;
  late TextEditingController controller;
  late String hintText;
  late TextInputType inputType;
  late int maxLine;
  late int maxCharacter;
  late bool focus;
  late Function onChanged;
  InputField({
    Key? key,
    required this.icon,
    required this.controller,
    required this.hintText,
    required this.inputType,
    required this.maxLine,
    required this.maxCharacter,
    required this.focus,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        autofocus: widget.focus,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Value  musn't be empty";
          } else if (value.length < 10) {
            return "Value length must be at least 10 characters ";
          } else if (value.length > widget.maxCharacter) {
            return "Value length mustn't be at more ${widget.maxCharacter} characters ";
          }

          return null;
        },
        controller: widget.controller,
        maxLines: widget.maxLine,
        keyboardType: widget.inputType,
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {});
        },
        cursorColor: Colors.purple,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          counterText:
              '${widget.controller.text.length.toString()}/${widget.maxCharacter}',
          fillColor: myConstants.themeColor.shade50,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontSize: 16.0,
            color: Colors.black38,
          ),
          prefixIcon: Container(
            decoration: BoxDecoration(
              color: myConstants.themeColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            margin: EdgeInsets.all(
              8.0,
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
