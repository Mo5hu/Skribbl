import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/services/game_service.dart';
import 'package:skribbl/services/player_service.dart';
import 'package:skribbl/widgets/background_image_container.dart';
import 'package:skribbl/widgets/card_with_title.dart';
import 'package:skribbl/widgets/loading_widget.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: Stack(
          children: [
            Center(
              child: CardWithTitle(
                content: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: JoinRoomColumn(),
                ),
                image: Image.asset('assets/images/find_room.png'),
              ),
            ),
            BackButton(
              color: Colors.white,
              onPressed: () => context.go('/advance'),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinRoomColumn extends StatefulWidget {
  const JoinRoomColumn({Key? key}) : super(key: key);

  @override
  _JoinRoomColumnState createState() => _JoinRoomColumnState();
}

class _JoinRoomColumnState extends State<JoinRoomColumn> {
  final tec = TextEditingController();

  var gameServiceProvider = GetIt.instance<GameService>();
  var playerServiceProvider = GetIt.instance<PlayerService>();
  var authService = GetIt.instance<AuthService>();

  String? err;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Text(
                'Room Code: ',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              Expanded(
                // width: MediaQuery.of(context).size.width * 0.1,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter room code here',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (code) async {
                    loadingWidget(context);
                    // LoadingWidget();
                    final tokenVar =
                        await authService.currentUser!.getIdToken();
                    gameServiceProvider.connect(tokenVar);
                    gameServiceProvider.joinRoomWithCode(context, code);
                  },
                  controller: tec,
                ),
              ),
            ],
          ),
          err != null
              ? Text(
                  err!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                )
              : Container(),
          ElevatedButton(
              onPressed: () async {
                loadingWidget(context);
                // LoadingWidget();
                var authToken = await authService.currentUser!.getIdToken();
                gameServiceProvider.connect(authToken);

                gameServiceProvider.joinRoomWithCode(context, tec.text);
              },
              child: const Text('JOIN ROOM'))
        ]);
  }
}
