import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/models/auth_exception.dart';
import 'package:skribbl/models/auth_user.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/utils/theme.dart';
import 'package:skribbl/widgets/background_image_container.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final AuthService _authService;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    log('no');
    _authService = GetIt.instance<AuthService>();
    log('no2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: StreamBuilder<AuthUser?>(
          stream: _authService.userChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
            final user = snapshot.data;
            return Column(
              children: [
                Text(
                  user?.uid ?? 'Not signed in',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: skribblPinkRed),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                else if (user == null)
                  Column(
                    children: [
                      // ElevatedButton(
                      //   onPressed: _onSignIn,
                      //   child: const Text('Sign In Anonymously'),
                      // ),
                      ElevatedButton(
                        onPressed: _onSignIn,
                        child: const Text('Sign In Googly'),
                      ),
                    ],
                  )
                else
                  Column(children: [
                    if (false)
                      // StreamBuilder(
                      //   stream: streamSocket.getResponse,
                      //   builder: (BuildContext context,
                      //       AsyncSnapshot<String> snapshot) {
                      //     log('here');
                      //     if (snapshot.hasError)
                      //       return Text(snapshot.error.toString());

                      //     // if (snapshot.connectionState == ConnectionState.waiting)
                      //     //   return CircularProgressIndicator.adaptive();

                      //     return Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Text(snapshot.data ?? 'no'),
                      //         ElevatedButton(
                      //           onPressed: () {
                      //             _socket!.emit('welcome');
                      //           },
                      //           child: Text('SEND'),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // ),
                      OutlinedButton(
                        onPressed: _onSignOut,
                        child: const Text('Sign Out'),
                      ),
                  ]),
                FutureBuilder<String>(
                    future: user?.getIdToken(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError ||
                          snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.data == null) {
                        return const SelectableText("Waitng ir error");
                      }

                      return SelectableText(snapshot.data ?? 'we');
                    }),
                TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierColor: Colors.transparent, //this works

                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xCF13243E),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('ACCOUNT INFO'),
                            content: Card(
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text("User Name: ${user?.uid}"),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Join ISIS'),
                              ),
                            ],
                          );
                        });
                  },
                  child: const Text('Show Dialog'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInAnonymously();
    } on AuthException catch (e) {
      final snackBar = SnackBar(content: Text(e.code));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSignOut() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signOut();
    } on AuthException catch (e) {
      final snackBar = SnackBar(content: Text(e.code));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
