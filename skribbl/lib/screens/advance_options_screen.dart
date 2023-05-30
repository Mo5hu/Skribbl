import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/widgets/background_image_container.dart';

class AdvanceOptionsScreen extends StatelessWidget {
  const AdvanceOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              /// Side icons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () {
                        GetIt.instance<AuthService>().signOut();
                      },
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

              /// Center buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text(
                            'QUICK MATCH',
                          ),
                        ),
                        const SizedBox(width: 40),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text(
                            'ADVANCE',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'HOW TO PLAY',
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
