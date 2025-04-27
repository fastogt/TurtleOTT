part of 'websocket_api_bloc.dart';

abstract class WebSocketApiEvent extends Equatable {
  const WebSocketApiEvent();

  @override
  List<Object?> get props => [];
}

class OnOpenEvent extends WebSocketApiEvent {
  const OnOpenEvent();

  @override
  List<Object?> get props => [];
}

class OnDisconnectEvent extends WebSocketApiEvent {
  const OnDisconnectEvent();

  @override
  List<Object?> get props => [];
}

class OnMessageEvent extends WebSocketApiEvent {
  final dynamic message;

  const OnMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class OnErrorEvent extends WebSocketApiEvent {
  final Exception error;

  const OnErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

class OnClosedEvent extends WebSocketApiEvent {
  final int? code;
  final String? reason;

  const OnClosedEvent(
    this.code,
    this.reason,
  );

  @override
  List<Object?> get props => [code, reason];
}
