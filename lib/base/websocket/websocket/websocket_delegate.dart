import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_delegate_base.dart';

class WebSocketDelegate extends WebSocketDelegateBase {
  WebSocketChannel? _socket;
  WebSocketDelegate(String url,
      {OnOpenCallback? onOpen,
      OnMessageCallback? onMessage,
      OnCloseCallback? onClose,
      OnErrorCallback? onError})
      : super(url, onOpen, onMessage, onClose, onError);

  @override
  Future<void> connect() async {
    final uri = Uri.parse(url);
    final sock = WebSocketChannel.connect(uri);
    _socket = sock;

    onOpen?.call();
    sock.stream.listen(onMessage, onDone: () {
      final code = sock.closeCode;
      final reason = sock.closeReason;
      onClose?.call(code, reason);
    }, onError: (Object error) {
      onError?.call(error);
    });
  }

  @override
  void send(dynamic data) {
    _socket?.sink.add(data);
  }

  @override
  void close() {
    _socket?.sink.close();
  }
}
