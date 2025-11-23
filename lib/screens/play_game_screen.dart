import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cs.dart';
import '../input_storage.dart';
import '../background_image_display.dart';
import 'stopwatch.dart';
import '../mycustom_outline_button.dart';
import 'play_game_timeup.dart';

class PlayGameScreen extends StatefulWidget {
  final int rendaSelectTimeValue; // 0=10秒, 1=60秒, 2=ENDLESS
  final int beforeScore;          // 直前のベストスコア（画面上の表示用）
  final String inputData;         // ニックネーム
  final InputStorage inputStorage;

  const PlayGameScreen({
    super.key,
    required this.rendaSelectTimeValue,
    required this.beforeScore,
    required this.inputData,
    required this.inputStorage,
  });

  @override
  PlayGameScreenState createState() => PlayGameScreenState();
}

class PlayGameScreenState extends State<PlayGameScreen> {
  int _counter = 0;
  bool isPlayStart = false;

  // stopwatch にアクセスするための key
  final GlobalKey<FlutterStopWatchState> _key =
  GlobalKey<FlutterStopWatchState>();

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
                  SizedBox(height: 20.h),

                  // ▼ 前回の BEST スコア表示
                  Text(
                    '${widget.beforeScore}',
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontFamily: fontName2,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  // ▼ タイマー（終了後に TimeUp へ遷移）
                  SizedBox(
                    height: 150.h,
                    child: FlutterStopWatch(
                      key: _key,
                      rendaSelectTimeValue: widget.rendaSelectTimeValue,
                      inputdata: widget.inputData,
                      numberScore: widget.beforeScore,
                      inputStorage: widget.inputStorage,

                      onTimeUp: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayGameTimeUp(
                              score: _counter,
                              name: widget.inputData,
                              mode: widget.rendaSelectTimeValue,
                              inputStorage: widget.inputStorage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // ▼ 現在の TAP カウント
                  Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 70.sp,
                      color: Colors.white,
                      fontFamily: fontName2,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // ▼ TAP ボタン
                  MyCustomOutlineButton(
                    width: 0.8.sw,
                    text: "TAP!",
                    color: Colors.red.withOpacity(0.3),
                    edge: 2.w,
                    redius1: 30.r,
                    redius2: 10.r,
                    fontsize: 55.sp,
                    onPressed: () {
                      // ゲームスタート（1回だけ）
                      if (!isPlayStart) {
                        isPlayStart = true;
                        _key.currentState?.startStopWatch();
                      }

                      // 時間切れ後は加算しない
                      if (_key.currentState?.isTimeUpFlag == false) {
                        setState(() {
                          _counter++;
                        });

                        // stopwatch 内の scoreCount を更新
                        _key.currentState?.scoreCount = _counter;

                        // ENDLESS の最終タップ時刻を更新
                        _key.currentState?.updateTapTime();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
