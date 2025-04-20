import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  const BackgroundContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/background_login.png', fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.3)),
        child,
      ],
    );
  }
}
