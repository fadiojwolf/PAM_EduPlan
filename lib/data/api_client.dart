import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

/// Общий скелет запроса с тремя слоями отказа (C8) — написан один раз,
/// им пользуются оба репозитория.
///   слой 1: дорога упала        → бросает, ловится по ТИПАМ (+ .timeout);
///   слой 2: сервер сказал «нет» → не бросает, читается через if из статуса;
///   слой 3: тело-сюрприз        → FormatException / TypeError при разборе.
/// Все ветки стекаются в Err(msg) — UI знает только Result.
class ApiClient {
  ApiClient(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized; // решает корень: назад на login
  static const _timeout = Duration(seconds: 8);

  // 401 = пропуск умер: token выбрасывается (C9), корень навигирует.
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  Future<Result<T>> call<T>({
    required String method,
    required String path,
    Map<String, String>? query,
    Object? body,
    required Set<int> okStatuses,
    required T Function(String body) parse,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await tokens.read() ?? ''}',
      };
      final Future<http.Response> request = switch (method) {
        'GET' => http.get(uri, headers: headers),
        'POST' => http.post(uri, headers: headers, body: jsonEncode(body)),
        'PUT' => http.put(uri, headers: headers, body: jsonEncode(body)),
        'DELETE' => http.delete(uri, headers: headers),
        _ => throw ArgumentError('Unsupported method: $method'),
      };
      final res = await request.timeout(_timeout); // timeout обязателен

      if (res.statusCode == 401) return Err(await _sessionDied());
      if (!okStatuses.contains(res.statusCode)) {
        return Err(apiMessage(res)); // слой 2, перевод конверта
      }
      return Ok(parse(res.body)); // слой 3 ловится ниже
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }
}
