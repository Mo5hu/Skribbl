import 'package:flutter/material.dart';

class CardWithTitle extends StatelessWidget {
  const CardWithTitle({
    Key? key,
    required this.content,
    required this.image,
  }) : super(key: key);

  final Widget content;
  final Image image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(top: 48),
            color: const Color(0xFF13243E).withOpacity(.71),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              child: content,
            ),
          ),

          /// This goes behind the image
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Container(
              width: 240,
              height: 4,
              color: const Color(0xFF13243E).withOpacity(1),
            ),
          ),
          image,
        ],
      ),
    );
  }
}
