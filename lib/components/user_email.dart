import 'package:flutter/material.dart';

class userEmailComp extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool resolved;

  userEmailComp({super.key, required this.text, required this.onTap, this.resolved = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[500], decoration: (resolved ? TextDecoration.lineThrough : TextDecoration.none),
        overflow: TextOverflow
            .ellipsis, // Prevent overflow in case of long text
      )
    ));
  }
}