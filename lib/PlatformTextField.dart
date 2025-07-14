import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType type;
  final int maxLines;

  const PlatformTextField(
      {Key? key,
      required this.labelText,
      required this.controller,
      required this.type,
      this.maxLines = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoTextField(
            keyboardType: type,
            placeholder: labelText,
            controller: controller,
            autocorrect: false,
            showCursor: true,
            cursorColor: CupertinoColors.activeGreen,
            prefix: CupertinoButton(
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.black54,
              ),
              onPressed: () {},
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.lightBackgroundGray,
              border: Border.all(
                color: CupertinoColors.lightBackgroundGray,
                width: 2,
              ),
            ),
          )
        : TextFormField(
            style: const TextStyle(fontSize: 18),
            keyboardType: type,
            maxLines : maxLines,
            decoration: InputDecoration(
                label: Text(labelText),
                border: const OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 2, color: CupertinoColors.lightBackgroundGray)),
                prefixIcon:
                    const Icon(Icons.person_outline_rounded, color: Colors.black54),
                labelStyle: const TextStyle(color: Colors.black54),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 2, color: Colors.black),
                )),
            controller: controller,
          );
  }
}
