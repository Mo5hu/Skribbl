import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skribbl/screens/advance_options_screen.dart';
import 'package:skribbl/screens/advance_screen.dart';
import 'package:skribbl/screens/create_room_screen.dart';
import 'package:skribbl/screens/home_screen.dart';
import 'package:skribbl/screens/join_room_screen.dart';
import 'package:skribbl/screens/login_screen.dart';
import 'package:skribbl/screens/painting_screen.dart';
import 'package:skribbl/screens/public_rooms.dart';
import 'package:skribbl/screens/select_rooms_screen.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/services/firebase_auth_service.dart';
import 'package:skribbl/services/game_service.dart';
import 'package:skribbl/services/game_service_impl.dart';
import 'package:skribbl/services/player_service.dart';
import 'package:skribbl/services/player_service_impl.dart';
import 'package:skribbl/utils/theme.dart';
import 'package:skribbl/widgets/background_image_container.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

  runApp(MyApp());
}

Future<FirebaseApp> _initialization() async {
  Wakelock.enable();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setSystemUIChangeCallback((isFullscreen) async {
    log('callback:$isFullscreen');
    if (!isFullscreen) {
      await Future.delayed(
        const Duration(seconds: 1),
        () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      );
    }
  });
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  final app = await Firebase.initializeApp();

  GetIt.instance.registerSingleton<AuthService>(FirebaseAuthService());
  GetIt.instance.registerSingleton<GameService>(GameServiceImpl());
  GetIt.instance.registerSingleton<PlayerService>(PlayerServiceImpl());

  /// TODO: register remaining services here
  log(app.options.appId);
  return app;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final firebaseFuture = _initialization();
  // late final GameService gameServiceProvider;
  // late final AuthService authService;
  // late final Stream<bool> connectionStream$;

  @override
  void initState() {
    precacheImage(
      Image.asset("assets/images/background.png").image,
      context,
    ).then((value) => print('cached'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: firebaseFuture,
      builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
        print('builder');
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BackgroundImageContainer();
        }
        // gameServiceProvider = GetIt.instance<GameService>();
        // authService = GetIt.instance<AuthService>();
        // connectionStream$ = gameServiceProvider.getSocketConnectionState();
        // if (snapshot.connectionState == ConnectionState.done) {
        //   connectSocket();
        // }
        final _router = GoRouter(
          routes: [
            GoRoute(
              path: '/', builder: (context, state) => const HomeScreen(),

              // StreamBuilder<bool>(
              //   stream: connectionStream$,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.active) {
              //       if (snapshot.hasData) {
              //         var connectionState = snapshot.data!;

              //         return connectionState
              //             ? const HomeScreen()
              //             : const CustomTextWidget(text: 'Disconnected');
              //       }
              //     }
              //     return const CustomTextWidget(
              //         text: 'Waiting for connection...');
              //   },
              // ),
            ),
            GoRoute(
              path: '/login',
              builder: (_, __) => const LoginScreen(),
            ),
            GoRoute(
              path: '/advance',
              builder: (_, __) => const AdvanceScreen(),
            ),
            GoRoute(
              path: '/create-room',
              builder: (_, __) => const CreateRoomScreen(),
            ),
            GoRoute(
              path: '/public-rooms',
              builder: (_, __) => const SelectRoomsScreen(),
            ),
            GoRoute(
              path: '/join-room',
              builder: (_, __) => const JoinRoomScreen(),
            ),
            GoRoute(
              path: '/public-room',
              builder: (_, __) => const PublicRooms(),
            ),
          ],
          redirect: (state) {
            final isLoggedIn =
                GetIt.instance<AuthService>().currentUser != null;
            final loggingIn = state.subloc == '/login';
            if (!isLoggedIn) return loggingIn ? null : '/login';

            // if the user is logged in but still on the login page, send them to
            // the home page
            // print(state.subloc.toString());
            if (loggingIn) return '/';
            // if (gameServiceProvider.socketConnectedStatus() == false)
            // return '/';

            // no need to redirect at all
            return null;
          },
          refreshListenable: GoRouterRefreshStream(
            GetIt.instance<AuthService>().userChanges(),
          ),
        );

        return ProviderScope(
          child: MaterialApp.router(
            title: 'Skribbl clone',
            routeInformationParser: _router.routeInformationParser,
            routerDelegate: _router.routerDelegate,
          ),
        );
      },
    );
  }

  // void connectSocket() async {
  //   var authUser = authService.currentUser!;
  //   if (authUser.displayName == null) {
  //     var length = authUser.uid.length;
  //     await authUser.updateName('Guest-' + authUser.uid.substring(length - 4));
  //   }

  //   var idToken = await authUser.getIdToken();
  //   gameServiceProvider.connect(idToken);
  // }
}

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              /// Side icons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.help),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    /// Game Title
                    Text(
                      title,
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
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text(
                                    'QUICK MATCH',
                                    style: GoogleFonts.montserrat(
                                      textStyle:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 40),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdvanceOptionsScreen(),
                                        ));
                                  },
                                  child: Text(
                                    'ADVANCE',
                                    style: GoogleFonts.montserrat(
                                      textStyle:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text(
                                'HOW TO PLAY',
                                style: GoogleFonts.montserrat(
                                  textStyle:
                                      Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
