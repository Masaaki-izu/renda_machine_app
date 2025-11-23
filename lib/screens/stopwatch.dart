import 'dart:async';
import 'package:flutter/material.dart';
import '../cs.dart';
import '../input_storage.dart';

class FlutterStopWatch extends StatefulWidget {
  final int rendaSelectTimeValue;
  final String inputdata;
  final int numberScore;
  final InputStorage inputStorage;

  /// ★ PlayGameScreen から渡す「TIME UP コールバック」
  final VoidCallback onTimeUp;

  const FlutterStopWatch({
    super.key,
    required this.rendaSelectTimeValue,
    required this.inputdata,
    required this.numberScore,
    required this.inputStorage,
    required this.onTimeUp,      // ★ 追加
  });

  @override
  FlutterStopWatchState createState() => FlutterStopWatchState();
}

class FlutterStopWatchState extends State<FlutterStopWatch> {
  Timer? timer;
  Timer? blinkTimer;
  Timer? noTapTimer;

  late StreamController<int> streamController;
  late Stream<int> timerStream;

  bool isTimeUpFlag = false;
  bool showText = true;
  bool isEndlessMode = false;

  int counter = 0;
  int scoreCount = 0;

  DateTime lastTapTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    streamController = StreamController<int>();
    timerStream = streamController.stream;
  }

  /// ▼ PlayGameScreen 側が TAP した時に呼び出す
  void updateTapTime() {
    lastTapTime = DateTime.now();
  }

  /// ▼ ゲーム開始
  void startStopWatch() {
    counter = widget.rendaSelectTimeValue == 0
        ? 10
        : widget.rendaSelectTimeValue == 1
        ? 60
        : 120;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isEndlessMode) {
        // ▼ カウントダウン
        if (counter > 0) {
          counter--;
          streamController.add(counter);
          setState(() {});
        } else {
          // ▼ ENDLESS に突入
          if (widget.rendaSelectTimeValue == 2) {
            isEndlessMode = true;
            counter = 0;
            _startBlink();
            _startNoTapCheck();
            streamController.add(counter);
            setState(() {});
          } else {
            _finish(t);
          }
        }
      } else {
        // ▼ ENDLESS カウントアップ
        counter++;
        streamController.add(counter);
        setState(() {});
      }
    });
  }

  /// ▼ ENDLESS 点滅
  void _startBlink() {
    blinkTimer = Timer.periodic(
      const Duration(milliseconds: 300),
          (t) {
        showText = !showText;
        setState(() {});
      },
    );
  }

  /// ▼ ENDLESS 無操作 5秒
  void _startNoTapCheck() {
    noTapTimer = Timer.periodic(
      const Duration(seconds: 1),
          (t) {
        final diff = DateTime.now().difference(lastTapTime).inSeconds;
        if (diff >= 5) {
          _finish(timer);
        }
      },
    );
  }

  /// ▼ TIME UP 共通処理
  void _finish(Timer? t) {
    t?.cancel();
    blinkTimer?.cancel();
    noTapTimer?.cancel();

    isTimeUpFlag = true;
    streamController.close();

    // ▼ 名前別・モード別スコアを保存する
    widget.inputStorage.saveScore(
      widget.inputdata,
      widget.rendaSelectTimeValue,
      scoreCount,
    );

    // ▼ PlayGameScreen に通知（画面遷移）
    widget.onTimeUp();
  }

  @override
  void dispose() {
    timer?.cancel();
    blinkTimer?.cancel();
    noTapTimer?.cancel();
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 80,
      fontFamily: fontName2,
      color: Colors.white,
    );

    return Center(
      child: StreamBuilder<int>(
        stream: timerStream,
        builder: (context, snapshot) {
          final time = snapshot.data ?? counter;

          if (isEndlessMode && !showText) {
            return Text(" ", style: textStyle);
          }

          return Text("$time", style: textStyle);
        },
      ),
    );
  }
}
