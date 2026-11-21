import 'package:shared_preferences/shared_preferences.dart';

/// Пропуск (JWT) поверх shared_preferences. Остальной код не знает, где он
/// хранится. Пароль локально не пишется НИКОГДА — token заменим и истекает.
class TokenStore {
  static const _key = 'auth_token';

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key); // null: не вошёл

  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token); // login → setString
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key); // logout И 401: мёртвый пропуск выбрасывают
  }
}
