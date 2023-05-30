import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skribbl/widgets/card_with_title.dart';

class InstructionsView extends StatelessWidget {
  const InstructionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardWithTitle(
        image: Image.asset('assets/images/how_to_play.png'),
        content: DefaultTextStyle.merge(
          style: GoogleFonts.montserrat().copyWith(
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'skribbl.io is a multiplayer drawing and guessing game.',
              ),
              SizedBox(height: 20),
              Text(
                'One game consists of a few rounds in which every round '
                'someone has to draw their chosen word and others have '
                'to guess it to gain points! The person with the most points '
                'at the end of game will then be crowned as the '
                'winner!',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
