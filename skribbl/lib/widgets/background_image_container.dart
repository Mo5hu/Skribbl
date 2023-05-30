import 'package:flutter/material.dart';

class BackgroundImageContainer extends StatelessWidget {
  const BackgroundImageContainer({
    Key? key,
    this.assetName,
    this.bundle,
    this.package,
    this.child,
  }) : super(key: key);

  final String? assetName;
  final AssetBundle? bundle;
  final String? package;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
              assetName ?? "assets/images/background.png",
              bundle: bundle,
              package: package,
            ),
            fit: BoxFit.cover),
      ),
      child: child,
    );
  }
}
