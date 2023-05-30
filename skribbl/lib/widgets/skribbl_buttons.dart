import 'package:flutter/material.dart';

class CardIconButton extends StatelessWidget {
  const CardIconButton({
    Key? key,
    required this.iconButton,
  }) : super(key: key);

  final IconButton iconButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.74),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      child: iconButton,
    );
  }
}
