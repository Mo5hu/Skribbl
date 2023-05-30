import 'package:flutter/material.dart';
import 'package:skribbl/widgets/card_with_title.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardWithTitle(
        image: Image.asset('assets/images/settings.png'),
        content: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodyText2!.copyWith(
                color: Colors.white,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Language'),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 128,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(4),
                          isDense: true,
                          hintText: "Select language",
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            child: Text('English'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: 200,
                  // constraints: BoxConstraints.tightFor(width: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SlimMaterialButton(
                        text: 'Manage Data Collection',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      SlimMaterialButton(
                        text: 'Privacy Policy',
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      SlimMaterialButton(
                        text: 'Terms Of Use',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              SlimMaterialButton(
                text: 'Show Account Support ID',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlimMaterialButton extends StatelessWidget {
  const SlimMaterialButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
