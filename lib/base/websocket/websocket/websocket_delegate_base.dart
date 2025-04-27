typedef OnMessageCallback = void Function(dynamic msg);
typedef OnCloseCallback = void Function(int? code, String? reason);
typedef OnOpenCallback = void Function();
typedef OnErrorCallback = void Function(Object error);

abstract class WebSocketDelegateBase {
  final String url;
  final OnOpenCallback? onOpen;
  final OnMessageCallback? onMessage;
  final OnCloseCallback? onClose;
  final OnErrorCallback? onError;

  WebSocketDelegateBase(this.url, this.onOpen, this.onMessage, this.onClose, this.onError);

  Future<void> connect();

  void send(dynamic data);

  void close();
}
