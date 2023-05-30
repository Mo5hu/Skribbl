import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:skribbl/providers/auth_user_provider.dart';
import 'package:skribbl/services/auth_service.dart';
import 'package:skribbl/widgets/card_with_title.dart';
import 'package:skribbl/widgets/input_dialog.dart';

class AccountInfoView extends ConsumerWidget {
  AccountInfoView({
    Key? key,
    required this.games,
    required this.wins,
    required this.onSignOut,
  }) : super(key: key);

  final int games;
  final int wins;
  final Function() onSignOut;
  final user$ = GetIt.instance<AuthService>().userChanges();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const loadingWidget = Center(child: CircularProgressIndicator.adaptive());

    return ref.watch(authUserProvider).when(
          data: (user) {
            if (user == null) return loadingWidget;
            return Center(
              child: CardWithTitle(
                image: Image.asset('assets/images/account_info.png'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox.square(
                                dimension: 80,
                                child: Image.network(
                                  user.photoURL != null
                                      ? user.photoURL!
                                      : 'https://avatars.dicebear.com/api/micah/${user.uid}.png',
                                  fit: BoxFit.scaleDown,
                                  frameBuilder: (context, child, _, __) {
                                    return Container(
                                      color: Colors.amber,
                                      child: child,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Username:'),
                                SizedBox(height: 4),
                                Text('Account ID:'),
                                SizedBox(height: 4),
                                Text('number of play:'),
                                SizedBox(height: 4),
                                Text('number of wins:'),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final name = await showDialog<String>(
                                        context: context,
                                        builder: (context) {
                                          return SkribblDialog(
                                            content: TextFormField(
                                              autofocus: true,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderSide:
                                                        BorderSide.none),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              onFieldSubmitted: (val) =>
                                                  Navigator.pop(
                                                      context, val.trim()),
                                            ),
                                          );
                                        },
                                      );
                                      log(name ?? 'empty');

                                      if (name == null || name.isEmpty) return;

                                      await user.updateName(name);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.displayName ?? 'Not set',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2!
                                              .copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.edit, size: 16),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (context) => SkribblDialog(
                                        content: TextButton.icon(
                                          onPressed: () => Clipboard.setData(
                                            ClipboardData(text: user.uid),
                                          ),
                                          icon: const Icon(Icons.copy,
                                              color: Colors.white),
                                          label: Text(
                                            user.uid,
                                            style: Theme.of(context)
                                                .textTheme
                                                .button!
                                                .copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Show Account ID',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(games.toString()),
                                  const SizedBox(height: 4),
                                  Text(wins.toString()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    RawMaterialButton(
                      onPressed: onSignOut,
                      child: Image.asset('assets/images/sign_in.png'),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => loadingWidget,
          error: (err, stack) => Text(err.toString()),
        );
  }
}
