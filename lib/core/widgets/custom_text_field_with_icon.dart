import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldWithIcon extends StatefulWidget {
  const CustomTextFieldWithIcon({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.onIconPressed,
    this.onChanged,
    this.inputFormatters,
    this.isNumeric = false,
  });

  final TextEditingController controller;
  final void Function(String) onSubmitted;
  final String? Function(String?)? validator;
  final Function()? onIconPressed;
  final void Function(String _)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool isNumeric;

  @override
  State<CustomTextFieldWithIcon> createState() => _CustomTextFieldWithIconState();
}

class _CustomTextFieldWithIconState extends State<CustomTextFieldWithIcon> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(convertArabicNumbersToEnglish);
  }

  @override
  void dispose() {
    widget.controller.removeListener(convertArabicNumbersToEnglish);
    super.dispose();
  }

  void convertArabicNumbersToEnglish() {
    if (widget.isNumeric) {
      final text = widget.controller.text;
      final convertedText = text.replaceAllMapped(
        RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 0x660).toString(),
      );

      if (text != convertedText) {
        widget.controller.value = widget.controller.value.copyWith(
          text: convertedText,
          selection: TextSelection.collapsed(offset: convertedText.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // validator: validator,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      onChanged: widget.onChanged,
      cursorHeight: 15,
      // onSubmitted: onSubmitted,
      controller: widget.controller,
      inputFormatters: widget.inputFormatters,
      onTap: () =>
          widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length),

      // onTapOutside: onTapOutside,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        disabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white, // Change the border color
            width: 2.0, // Change the border width
          ),
          borderRadius: BorderRadius.circular(5.0), // Adjust border radius
        ),
        border: UnderlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black, // Change the border color
            width: 2.0, // Change the border width
          ),
          borderRadius: BorderRadius.circular(5.0), // Adjust border radius
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.blue, // Change the border color when focused
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        suffixIcon: IconButton(
          onPressed: widget.onIconPressed,
          focusNode: FocusNode(skipTraversal: true),
          icon: const Icon(Icons.search),
        ),
        // Add an icon as a prefix

        contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
        // Center the text vertically
      ),
      textAlign: TextAlign.center,
      // Center the text horizontally
    );
  }
}
