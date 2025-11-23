import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../background_image_display.dart';
import 'home_screen.dart';
import '../input_storage.dart';

class PlayGameTimeUp extends StatelessWidget {
  final int score;
  final String name;
  final int mode;                     // 0=10s, 1=60s, 2=ENDLESS
  final InputStorage inputStorage;

  const PlayGameTimeUp({
    super.key,
    required this.score,
    required this.name,
    required this.mode,
    required this.inputStorage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundImageDisplay(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 40.h),

                  Text(
                    "TIME UP!",
                    style: TextStyle(
                      fontSize: 55.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  Text(
                    "Player : $name",
                    style: TextStyle(
                      fontSize: 28.sp,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Text(
                    "SCORE",
                    style: TextStyle(
                      fontSize: 32.sp,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    "$score",
                    style: TextStyle(
                      fontSize: 80.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),

                  SizedBox(height: 60.h),

                  // HOME
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(
                            inputStorage: inputStorage,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(220.w, 55.h),
                    ),
                    child: Text(
                      "HOME",
                      style: TextStyle(fontSize: 26.sp),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // RETRY
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: Size(220.w, 55.h),
                    ),
                    child: Text(
                      "RETRY",
                      style: TextStyle(fontSize: 26.sp),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
