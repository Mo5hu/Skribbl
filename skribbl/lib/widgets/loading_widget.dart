import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/services/game_service.dart';

void loadingWidget(BuildContext context) {
  Timer _timer = Timer(const Duration(seconds: 10), () {});
  final gameServiceProvider = GetIt.instance<GameService>();

  showDialog(
      // The user CANNOT close this dialog  by pressing outsite it
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return StreamBuilder<bool>(
            stream: gameServiceProvider.getJoinRoomStateStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data != null && snapshot.data == false) {
                  return Dialog(
                    backgroundColor: const Color.fromARGB(80, 0, 0, 0),
                    child: SizedBox(
                      height: 150,
                      width: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            gameServiceProvider.getJoinRoomError(),
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          TextButton(
                              onPressed: () {
                                print('error join room state');
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 128, 101, 31)),
                              ))
                        ],
                      ),
                    ),
                  );
                }
              }

              return Dialog(
                backgroundColor: const Color.fromARGB(80, 0, 0, 0),
                child: SizedBox(
                  height: 150,
                  width: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const CircularProgressIndicator(),
                      TextButton(
                          onPressed: () {
                            if (_timer.isActive) {
                              _timer.cancel();
                            }
                            _timer = Timer(const Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                color: Color.fromARGB(255, 128, 101, 31)),
                          ))
                    ],
                  ),
                ),
              );
            });
      });
}
