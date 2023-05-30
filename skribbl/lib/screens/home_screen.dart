import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:skribbl/models/room.dart';
import 'package:skribbl/models/room_request.dart';
import 'package:skribbl/screens/account_info_view.dart';
import 'package:skribbl/screens/home_view.dart';
import 'package:skribbl/screens/instructions_view.dart';
import 'package:skribbl/screens/settings_view.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/services/game_service.dart';
import 'package:skribbl/services/player_service.dart';
import 'package:skribbl/widgets/background_image_container.dart';
import 'package:skribbl/widgets/loading_widget.dart';
import 'package:skribbl/widgets/skribbl_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = PageController();
  final authService = GetIt.instance<AuthService>();
  final gameServiceProvider = GetIt.instance<GameService>();
  bool retryBtnEnabled = true;

  late final Stream<bool> connectionStream$;

  Future<void> _animateTo(int index) async {
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    // connectionStream$ = gameServiceProvider.getSocketConnectionState();
    // if (!gameServiceProvider.socketConnectedStatus()) {
    //   connectSocket();
    //   gameServiceProvider.setSocketRequest(true);
    // }
    var authUser = authService.currentUser!;
    if (authUser.displayName == null) {
      var length = authUser.uid.length;
      authUser.updateName('Guest-' + authUser.uid.substring(length - 4));
    }
  }

  // TODO: have to find a better way of doing this
  @override
  void dispose() {
    // gameServiceProvider.disconnect();
    super.dispose();
  }

  // void connectSocket() async {

  //   var idToken = await authUser.getIdToken();
  //   gameServiceProvider.connect(idToken);
  // }

  @override
  Widget build(BuildContext context) {
    gameServiceProvider.setScreenSize(MediaQuery.of(context).size);
    return Scaffold(
      body: BackgroundImageContainer(
        child: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller,
              scrollDirection: Axis.vertical,
              children: [
                HomeView(
                  onAdvance: () {
                    context.push('/advance');
                  },
                  onQuickMatch: () async {
                    loadingWidget(context);

                    var playerServiceProvider = GetIt.instance<PlayerService>();

                    var authService = GetIt.instance<AuthService>();
                    var authUser = authService.currentUser!;
                    final tokenVar = await authUser.getIdToken();
                    List<Room> rooms =
                        await playerServiceProvider.getPublicRooms(tokenVar);
                    gameServiceProvider.connect(tokenVar);
                    if (rooms.isNotEmpty) {
                      gameServiceProvider.joinRoom(context, rooms.last);
                    } else {
                      gameServiceProvider.createRoom(
                          context,
                          RoomRequest(
                              rounds: 3,
                              drawTime: drawTimePresets.first,
                              numberOfPlayers: 3));
                    }
                  },
                  onHowToPlay: () => _animateTo(3),
                ),
                AccountInfoView(
                  games: 8,
                  wins: 5,
                  onSignOut: GetIt.instance<AuthService>().signOut,
                ),
                const SettingsView(),
                const InstructionsView(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CardIconButton(
                    iconButton: IconButton(
                      color: const Color(0xFFD57275),
                      icon: const Icon(Icons.home_outlined),
                      tooltip: 'Home',
                      onPressed: () => _animateTo(0),
                    ),
                  ),
                  CardIconButton(
                    iconButton: IconButton(
                      color: const Color(0xFFFBC843),
                      icon: const Icon(Icons.person_outline),
                      tooltip: 'Account',
                      onPressed: () => _animateTo(1),
                    ),
                  ),
                  CardIconButton(
                    iconButton: IconButton(
                      color: const Color(0xFF56D0FD),
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () => _animateTo(2),
                    ),
                  ),
                  CardIconButton(
                    iconButton: IconButton(
                      color: const Color(0xFF0FAE2E),
                      icon: const Icon(Icons.help_outline),
                      tooltip: 'How to play',
                      onPressed: () => _animateTo(3),
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //   top: 12,
            //   right: 12,
            //   child: StreamBuilder<bool>(
            //     stream: connectionStream$,
            //     builder: (context, snapshot) {
            //       print("connection State: " +
            //           snapshot.connectionState.toString());
            //       if (snapshot.connectionState == ConnectionState.active) {
            //         if (snapshot.hasData) {
            //           var connectionState = snapshot.data!;

            //           if (connectionState) {
            //             // setState(() {
            //             //   retryBtnEnabled = true;
            //             // });
            //           }

            //           return connectionState
            //               ? const Text(
            //                   'Connected',
            //                   style: TextStyle(color: Colors.green),
            //                 )
            //               : const Text(
            //                   'Disconnected',
            //                   style: TextStyle(color: Colors.red),
            //                 );
            //         }
            //       }
            //       if (!gameServiceProvider.getSocketRequest()) {
            //         connectSocket();
            //       }
            //       return const Text(
            //         'Waiting for connection...',
            //         style: TextStyle(color: Colors.red),
            //       );
            //     },
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
