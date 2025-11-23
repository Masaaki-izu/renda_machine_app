import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InputStorage {
  static const String keyUserName = "current_user_name";
  static const String keyTimeMode = "current_time_mode";

  static const String keyAllUsers = "all_users";

  static const String keyGlobal10 = "global_best_10";
  static const String keyGlobal60 = "global_best_60";
  static const String keyGlobalEnd = "global_best_end";

  /// ▼ 初期化（main.dart から使用）
  static Future<InputStorage> init() async {
    return InputStorage();
  }

  // --------------------------
  // ▼ ニックネーム保存/読込
  // --------------------------
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserName, name);
  }

  Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? "";
  }

  // --------------------------
  // ▼ 時間モード保存/読込（0/1/2）
  // --------------------------
  Future<void> saveTimeMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyTimeMode, mode);
  }

  Future<int> loadTimeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyTimeMode) ?? 0;
  }

  // --------------------------
  // ▼ スコア保存（名前・モード別）
  // --------------------------
  Future<void> saveScore(String name, int mode, int score) async {
    final prefs = await SharedPreferences.getInstance();

    String jsonString = prefs.getString(keyAllUsers) ?? "{}";
    Map<String, dynamic> allUsersMap = json.decode(jsonString);

    Map<String, dynamic> userData = allUsersMap[name] ?? {
      "10": 0,
      "60": 0,
      "end": 0,
    };

    String key = mode == 0 ? "10" : mode == 1 ? "60" : "end";

    if (score > (userData[key] ?? 0)) {
      userData[key] = score;
    }

    allUsersMap[name] = userData;

    await prefs.setString(keyAllUsers, json.encode(allUsersMap));

    await _updateGlobalBest(prefs, mode, score);
  }

  // --------------------------
  // ▼ グローバルBEST更新
  // --------------------------
  Future<void> _updateGlobalBest(
      SharedPreferences prefs, int mode, int score) async {
    String globalKey =
    mode == 0 ? keyGlobal10 : mode == 1 ? keyGlobal60 : keyGlobalEnd;

    int before = prefs.getInt(globalKey) ?? 0;

    if (score > before) {
      await prefs.setInt(globalKey, score);
    }
  }

  // --------------------------
  // ▼ 個人BEST読込
  // --------------------------
  Future<int> loadUserBestScore(String name, int mode) async {
    final prefs = await SharedPreferences.getInstance();

    String jsonString = prefs.getString(keyAllUsers) ?? "{}";
    Map<String, dynamic> allUsersMap = json.decode(jsonString);

    if (!allUsersMap.containsKey(name)) return 0;

    final userData = allUsersMap[name];

    return mode == 0
        ? (userData["10"] ?? 0)
        : mode == 1
        ? (userData["60"] ?? 0)
        : (userData["end"] ?? 0);
  }

  // --------------------------
  // ▼ グローバルBEST読込
  // --------------------------
  Future<int> loadGlobalBest(int mode) async {
    final prefs = await SharedPreferences.getInstance();

    return mode == 0
        ? (prefs.getInt(keyGlobal10) ?? 0)
        : mode == 1
        ? (prefs.getInt(keyGlobal60) ?? 0)
        : (prefs.getInt(keyGlobalEnd) ?? 0);
  }

  // --------------------------
  // ▼ 全ユーザー読込
  // --------------------------
  Future<Map<String, dynamic>> loadAllUsers() async {
    final prefs = await SharedPreferences.getInstance();

    String jsonString = prefs.getString(keyAllUsers) ?? "{}";
    return json.decode(jsonString);
  }
  // --------------------------
  // ▼ ユーザー削除
  // --------------------------
  Future<void> deleteUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(keyAllUsers);
    if (jsonStr == null) return;

    Map<String, dynamic> map = jsonDecode(jsonStr);
    map.remove(name);

    prefs.setString(keyAllUsers, jsonEncode(map));
  }
}
