import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:skribbl/models/room.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/services/game_service.dart';
import 'package:skribbl/services/player_service.dart';
import 'package:skribbl/widgets/background_image_container.dart';
import 'package:skribbl/widgets/loading_widget.dart';

import '../widgets/card_with_title.dart';

class PublicRooms extends StatefulWidget {
  const PublicRooms({Key? key}) : super(key: key);

  @override
  _PublicRoomsState createState() => _PublicRoomsState();
}

class _PublicRoomsState extends State<PublicRooms> {
  final gameServiceProvider = GetIt.instance<GameService>();
  final playerService = GetIt.instance<PlayerService>();
  final authService = GetIt.instance<AuthService>();

  List<Room>? rooms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: CardWithTitle(
                  content: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: FutureBuilder<String>(
                          future: authService.currentUser?.getIdToken(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              var authToken = snapshot.data!;
                              return FutureBuilder<List<Room>>(
                                  future:
                                      playerService.getPublicRooms(authToken),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      rooms = snapshot.data;
                                      if (rooms!.isEmpty) {
                                        return const Center(
                                          child: Text('No Rooms',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        );
                                      }
                                      return ListView.builder(
                                          itemCount: rooms!.length,
                                          itemBuilder: ((context, index) {
                                            var room = rooms![index];
                                            return ListTile(
                                              onTap: () async {
                                                loadingWidget(context);
                                                final tokenVar =
                                                    await authService
                                                        .currentUser!
                                                        .getIdToken();
                                                gameServiceProvider
                                                    .connect(tokenVar);
                                                gameServiceProvider.joinRoom(
                                                    context, room);
                                              },
                                              title: Text(
                                                'Room ${index + 1}',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              subtitle: Text(
                                                room.roomCode,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              trailing: Text(
                                                room.players.length.toString() +
                                                    ' Players',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            );
                                          }));
                                    }
                                    return const Center(
                                      child: Text(
                                        'Fetching Data from our servers',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  });
                            }
                            return Container();
                          })),
                  image: Image.asset('assets/images/find_room.png'),
                ),
              ),
              BackButton(
                color: Colors.white,
                onPressed: () => context.go('/advance'),
              ),
              Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () async {
                      setState(() {});
                      // TODO: refreshing 2 times
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
