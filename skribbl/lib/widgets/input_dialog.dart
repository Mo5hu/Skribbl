import 'package:flutter/material.dart';

/// Returns user input
class InputDialog extends StatelessWidget {
  const InputDialog({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      backgroundColor: const Color(0xFF13243E).withOpacity(.82),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 300,
            child: TextFormField(
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                hintText: hintText,
              ),
            ),
          ),
          const SizedBox(height: 20),
          RawMaterialButton(
            onPressed: () {},
            child: Image.asset('assets/images/join.png'),
          ),
        ],
      ),
    );
  }
}

class SkribblDialog extends StatelessWidget {
  const SkribblDialog({
    Key? key,
    required this.content,
  }) : super(key: key);

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      backgroundColor: const Color(0xFF13243E).withOpacity(.82),
      content: content,
    );
  }
}
