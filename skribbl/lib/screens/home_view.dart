import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skribbl/utils/theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    Key? key,
    required this.onQuickMatch,
    required this.onAdvance,
    required this.onHowToPlay,
  }) : super(key: key);

  final Function() onQuickMatch;
  final Function() onAdvance;
  final Function() onHowToPlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),

        /// Game Title
        Text(
          'TITLE GAME',
          style: GoogleFonts.oswald(
            textStyle: Theme.of(context)
                .textTheme
                .headline4!
                .copyWith(color: skribblPinkRed),
          ),
        ),
        const SizedBox(height: 20),

        /// Center buttons
        Card(
          margin: EdgeInsets.zero,
          // alignment: Alignment.center,
          color: const Color(0xFF13243E).withOpacity(0.89),
          // color: skribblOrange,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 200,
                      child: RawMaterialButton(
                        onPressed: onQuickMatch,
                        child: Image.asset('assets/images/quick_match.png'),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: RawMaterialButton(
                        onPressed: onAdvance,
                        child: Image.asset('assets/images/advance.png'),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: RawMaterialButton(
                    onPressed: onHowToPlay,
                    child: Image.asset('assets/images/how_to_play.png'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
