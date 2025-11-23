import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cs.dart';
import '../input_storage.dart';
import '../background_image_display.dart';
import '../screens/play_game_screen.dart';
import '../mycustom_outline_button.dart';

const int inputCharMax = 8;

class HomeScreen extends StatefulWidget {
  final InputStorage inputStorage;

  const HomeScreen({
    super.key,
    required this.inputStorage,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  String inputName = "";
  int rendaSelectTimeValue = 0;

  int best10 = 0;
  int best60 = 0;
  int bestEnd = 0;

  int global10 = 0;
  int global60 = 0;
  int globalEnd = 0;

  Map<String, dynamic> allUsers = {};

  bool isNameEntered = false;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _loadInitData();
  }

  // ----------------------------------------
  // ▼ 初期読込（名前・モード・全データ）
  // ----------------------------------------
  Future<void> _loadInitData() async {
    final savedName = await widget.inputStorage.loadUserName();
    final savedMode = await widget.inputStorage.loadTimeMode();

    inputName = savedName;
    rendaSelectTimeValue = savedMode;
    isNameEntered = inputName.isNotEmpty;

    await _loadRanking();
    await _loadAllUsers();

    setState(() => isLoaded = true);
  }

  // ----------------------------------------
  // ▼ ランキング読み込み
  // ----------------------------------------
  Future<void> _loadRanking() async {
    best10 = await widget.inputStorage.loadUserBestScore(inputName, 0);
    best60 = await widget.inputStorage.loadUserBestScore(inputName, 1);
    bestEnd = await widget.inputStorage.loadUserBestScore(inputName, 2);

    global10 = await widget.inputStorage.loadGlobalBest(0);
    global60 = await widget.inputStorage.loadGlobalBest(1);
    globalEnd = await widget.inputStorage.loadGlobalBest(2);

    setState(() {});
  }

  // ----------------------------------------
  // ▼ 全ユーザーデータ読み込み
  // ----------------------------------------
  Future<void> _loadAllUsers() async {
    allUsers = await widget.inputStorage.loadAllUsers();
    setState(() {});
  }

  // ----------------------------------------
  // ▼ UI 描画
  // ----------------------------------------
  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        const BackgroundImageDisplay(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    _globalBestDisplay(),
                    SizedBox(height: 15.h),

                    Text("Renda",
                        style: TextStyle(
                          fontSize: 53.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                    Text("Machine",
                        style: TextStyle(
                          fontSize: 53.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),

                    SizedBox(height: 10.h),

                    _nameInputButton(),
                    SizedBox(height: 10.h),

                    if (isNameEntered) _timeSelectButtons(),
                    SizedBox(height: 10.h),

                    if (isNameEntered) _playButton(context),
                    SizedBox(height: 10.h),

                    _userBestDisplay(),
                    SizedBox(height: 10.h),

                    _allUserRanking(),  // ← ここが全ユーザー一覧
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // ▼ グローバルベスト表示
  // -------------------------------------------------------
  Widget _globalBestDisplay() {
    return Container(
      width: 0.9.sw,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.yellowAccent, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text("Global Best",
              style: TextStyle(fontSize: 22.sp, color: Colors.yellowAccent)),
          SizedBox(height: 6),
          Text(
            "10s : $global10   /   60s : $global60   /   ENDLESS : $globalEnd",
            style: TextStyle(fontSize: 18.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // ▼ 個人ベスト表示
  // -------------------------------------------------------
  Widget _userBestDisplay() {
    return Container(
      width: 0.9.sw,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            "$inputName's Best",
            style: TextStyle(fontSize: 22.sp, color: Colors.lightBlueAccent),
          ),
          SizedBox(height: 6),
          Text("10s : $best10   /   60s : $best60   /   ENDLESS : $bestEnd",
              style: TextStyle(fontSize: 18.sp, color: Colors.white)),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // ▼ ニックネーム入力
  // -------------------------------------------------------
  Widget _nameInputButton() {
    return GestureDetector(
      onTap: () => _showNameDialog(),
      child: Container(
        width: 0.7.sw,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            inputName.isEmpty ? "Enter NickName" : inputName,
            style: TextStyle(color: Colors.black, fontSize: 22.sp),
          ),
        ),
      ),
    );
  }

  Future<void> _showNameDialog() async {
    _textController.text = inputName;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter NickName"),
        content: TextField(
          controller: _textController,
          maxLength: inputCharMax,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () {
                Navigator.pop(context, _textController.text);
              },
              child: const Text("OK")),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      inputName = result;
      isNameEntered = true;
      await widget.inputStorage.saveUserName(inputName);
      await _loadRanking();
      await _loadAllUsers();
      setState(() {});
    }
  }

  // -------------------------------------------------------
  // ▼ 時間モード選択
  // -------------------------------------------------------
  Widget _timeSelectButtons() {
    final colors = [Colors.blue, Colors.blue, Colors.blue];
    colors[rendaSelectTimeValue] = Colors.red;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _timeButton(0, colors[0]),
        SizedBox(width: 6),
        _timeButton(1, colors[1]),
        SizedBox(width: 6),
        _timeButton(2, colors[2]),
      ],
    );
  }

  Widget _timeButton(int index, Color color) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () async {
        rendaSelectTimeValue = index;
        await widget.inputStorage.saveTimeMode(index);
        setState(() {});
      },
      child: Text(
        selectGame[index],
        style: TextStyle(fontSize: 23.sp, color: Colors.white),
      ),
    );
  }

  // -------------------------------------------------------
  // ▼ PLAY ボタン
  // -------------------------------------------------------
  Widget _playButton(BuildContext context) {
    return MyCustomOutlineButton(
      text: "PLAY!",
      onPressed: () => _goPlay(context),
      color: Colors.redAccent.withOpacity(0.3),
      width: 0.8.sw,
      redius1: 30,
      edge: 2,
      redius2: 10,
      fontsize: 46.sp,
    );
  }

  Future<void> _goPlay(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayGameScreen(
          rendaSelectTimeValue: rendaSelectTimeValue,
          beforeScore: _getBeforeScore(),
          inputData: inputName,
          inputStorage: widget.inputStorage,
        ),
      ),
    ).then((_) async {
      await _loadRanking();
      await _loadAllUsers();
    });
  }

  int _getBeforeScore() {
    switch (rendaSelectTimeValue) {
      case 0:
        return best10;
      case 1:
        return best60;
      case 2:
      default:
        return bestEnd;
    }
  }

  // ----------------------------------------------
  // ▼ 全ユーザーランキング表示（削除ダイアログ＋スクロール対応）
  // ----------------------------------------------
  Widget _allUserRanking() {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.inputStorage.loadAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text(
            "Loading...",
            style: TextStyle(color: Colors.white),
          );
        }

        final allUsers = snapshot.data!;
        if (allUsers.isEmpty) {
          return Text(
            "No User Data",
            style: TextStyle(color: Colors.white),
          );
        }

        return Container(
          width: 0.9.sw,
          height: 300.h,   // ←★ A案：高さ300
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            border: Border.all(color: Colors.white),
          ),

          child: SingleChildScrollView(
            child: Column(
              children: [
                // ▼ ヘッダ
                Row(
                  children: [
                    _cell("Name", bold: true),
                    _cell("10s", bold: true),
                    _cell("60s", bold: true),
                    _cell("End", bold: true),
                  ],
                ),
                Divider(color: Colors.white),

                // ▼ データ行リスト
                ...allUsers.entries.map((entry) {
                  final name = entry.key;
                  final score = entry.value;

                  return Dismissible(
                    key: Key(name),
                    direction: DismissDirection.endToStart,

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),

                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("削除しますか？"),
                            content: Text("$name のデータを削除します。よろしいですか？"),
                            actions: [
                              TextButton(
                                child: Text("キャンセル"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: Text("OK"),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          );
                        },
                      );
                    },

                    onDismissed: (_) async {
                      await widget.inputStorage.deleteUser(name);
                      setState(() {});
                    },

                    child: Row(
                      children: [
                        _cell(name),
                        _cell(score["10"].toString()),
                        _cell(score["60"].toString()),
                        _cell(score["end"].toString()),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cell(String text, {bool bold = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
