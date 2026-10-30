/// «Сеть» mock-а: общая для всех mock-репозиториев задержка и переключатель
/// аварии. Единственный объект, о котором UI (профиль) знает из mock-мира —
/// леса демонстрации, исчезают на L5 вместе с mock-ом.
class MockNetwork {
  bool simulateError = false;

  static const latency = Duration(milliseconds: 800);
  static const errNetwork = 'Сервер не отвечает — повторите попытку';
}
