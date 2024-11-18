import 'package:flutter/material.dart';

class ResolveButton extends StatelessWidget {
  final void Function()? onTap;
  final bool resolved;
  const ResolveButton({super.key, required this.onTap, required this.resolved});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Icon(
          (resolved ? Icons.close : Icons.check),
          color: Colors.grey,
        ));
  }
}
