import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color backgroundColor;
  final String text;
  final Color textColor;
  final Color borderColor;
  const FollowButton(
      {Key? key,
      this.onPressed,
      required this.backgroundColor,
      required this.text,
      required this.textColor,
      required this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(5)),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
          width: 250,
          height: 27,
        ),
      ),
    );
  }
}
