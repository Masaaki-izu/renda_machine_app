import 'package:flutter/material.dart';
import 'package:flutter/services.dart';              // ★ 追加
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'input_storage.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ★ スマホの画面向きを縦に固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // SharedPreferences 初期化
  final storage = await InputStorage.init();

  runApp(MyApp(storage: storage));
}

class MyApp extends StatelessWidget {
  final InputStorage storage;

  const MyApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(inputStorage: storage),
        );
      },
    );
  }
}
