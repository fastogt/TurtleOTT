part of 'websocket_api_bloc.dart';

class WebSocketState {}

class WebSocketConnected extends WebSocketState {}

class WebSocketDisconnected extends WebSocketState {}

class WebSocketFailure extends WebSocketState {
  final String description;

  WebSocketFailure(this.description);

  factory WebSocketFailure.fromError(String error) {
    return WebSocketFailure('Socket error: $error');
  }
}

class WebSocketSendMessage extends WebSocketState {
  final Map<String, dynamic> data;

  WebSocketSendMessage(this.data);

  factory WebSocketSendMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketSendMessage(json['data']);
  }
}

class WebSocketShutdown extends WebSocketState {
  WebSocketShutdown();

  factory WebSocketShutdown.fromJson() {
    return WebSocketShutdown();
  }
}

class WebSocketReset extends WebSocketState {
  WebSocketReset();

  factory WebSocketReset.fromJson() {
    return WebSocketReset();
  }
}
