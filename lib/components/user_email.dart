import 'package:flutter/material.dart';

class userEmailComp extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const userEmailComp({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[500]),
        overflow: TextOverflow
            .ellipsis, // Prevent overflow in case of long text
      )
    );
  }
}