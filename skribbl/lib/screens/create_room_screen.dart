import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:skribbl/models/room_request.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/services/game_service.dart';
import 'package:skribbl/services/player_service.dart';
import 'package:skribbl/utils/theme.dart';
import 'package:skribbl/widgets/background_image_container.dart';
import 'package:skribbl/widgets/card_with_title.dart';
import 'package:skribbl/widgets/loading_widget.dart';

class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

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
                  child: RoomRequestColumn(),
                  // child: Column(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         Text('Rounds'),
                  //         CupertinoSlidingSegmentedControl<int>(
                  //           children: {
                  //             3: Text('3'),
                  //             5: Text('5'),
                  //             8: Text('8'),
                  //           },
                  //           onValueChanged: (val) {
                  //             log('$val');
                  //           },
                  //           backgroundColor: Colors.amber,
                  //         ),
                  //       ],
                  //     ),
                  //     Text('Rounds'),
                  //     Text('Draw Time'),
                  //     Text('Number of People'),
                  //     const SizedBox(height: 20),
                  //     RawMaterialButton(
                  //       onPressed: () {},
                  //       child: Image.asset('assets/images/go.png'),
                  //     ),
                  //   ],
                  // ),
                ),
                image: Image.asset('assets/images/create_room.png'),
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

class RoomRequestColumn extends StatefulWidget {
  const RoomRequestColumn({Key? key}) : super(key: key);

  @override
  _RoomRequestColumnState createState() => _RoomRequestColumnState();
}

class _RoomRequestColumnState extends State<RoomRequestColumn> {
  int _rounds = roundsPresets.first;
  int _drawTime = drawTimePresets.first;
  int _capacity = capacityPresets.first;

  var gameServiceProvider = GetIt.instance<GameService>();
  var playerService = GetIt.instance<PlayerService>();
  var authService = GetIt.instance<AuthService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Rounds'),
              ),
              Expanded(
                child: CupertinoSlidingSegmentedControl<int>(
                  children: {
                    for (var element in roundsPresets)
                      element: Text(element.toString())
                  },
                  onValueChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _rounds = val;
                    });
                  },
                  groupValue: _rounds,
                  thumbColor: skribblOrange,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Draw Time')),
              Expanded(
                child: CupertinoSlidingSegmentedControl<int>(
                  children: {
                    for (var element in drawTimePresets)
                      element: Text(element.toString())
                  },
                  onValueChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _drawTime = val;
                    });
                  },
                  groupValue: _drawTime,
                  thumbColor: skribblOrange,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Number of People')),
              Expanded(
                child: CupertinoSlidingSegmentedControl<int>(
                  children: {
                    for (var element in capacityPresets)
                      element: Text(element.toString())
                  },
                  onValueChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _capacity = val;
                    });
                  },
                  groupValue: _capacity,
                  thumbColor: skribblOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RawMaterialButton(
            onPressed: () async {
              loadingWidget(context);
              final roomData = RoomRequest(
                rounds: _rounds,
                drawTime: _drawTime,
                numberOfPlayers: _capacity,
              );
              final tokenVar = await authService.currentUser!.getIdToken();
              gameServiceProvider.connect(tokenVar);
              gameServiceProvider.createRoom(context, roomData);
            },
            child: Image.asset('assets/images/go.png'),
          ),
        ],
      ),
    );
  }
}
