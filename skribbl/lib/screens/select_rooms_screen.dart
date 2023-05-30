import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skribbl/widgets/background_image_container.dart';
import 'package:skribbl/widgets/card_with_title.dart';
import 'package:skribbl/widgets/skribbl_list_tiles.dart';

class SelectRoomsScreen extends StatelessWidget {
  const SelectRoomsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundImageContainer(
        child: Stack(
          children: [
            Center(
              child: CardWithTitle(
                content: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkribblListTile(
                        leading: Image.asset('assets/images/room_options.png'),
                        title: const Text('Host'),
                        subtitle: const Text('create room'),
                        onTap: () => context.go('/create-room'),
                      ),
                      const SizedBox(height: 8),
                      SkribblListTile(
                        leading: Image.asset('assets/images/room_options.png'),
                        title: const Text('Public'),
                        subtitle: const Text('find room'),
                        onTap: () => context.go('/public-rooms'),
                      ),
                      const SizedBox(height: 8),
                      SkribblListTile(
                        leading: Image.asset('assets/images/room_options.png'),
                        title: const Text('Private'),
                        subtitle: const Text('enter code'),
                        onTap: () {
                          /// TODO: SHOW CODE DIALOG
                        },
                      ),
                    ],
                  ),
                ),
                image: Image.asset('assets/images/find_room.png'),
              ),
            ),
            BackButton(
              color: Colors.white,
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}
