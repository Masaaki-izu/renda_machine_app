import 'package:flutter/material.dart';

/// 画面全体に背景画像を敷くウィジェット
class BackgroundImageDisplay extends StatelessWidget {
  final Widget? child;

  const BackgroundImageDisplay({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background_space.png"),
          fit: BoxFit.cover,   // 画面に合わせて拡大
        ),
      ),
      child: child,
    );
  }
}
