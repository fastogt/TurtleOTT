import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:dart_common/utils.dart';

import 'package:equatable/equatable.dart';
import 'package:turtleott/base/websocket/websocket/websocket_delegate.dart';

part 'websocket_api_event.dart';
part 'websocket_api_state.dart';

typedef OnRequestInfoCallback = WsConnectionInfo Function();

class WebSocketApiBloc extends Bloc<WebSocketApiEvent, WebSocketState> {
  WebSocketApiBloc() : super(WebSocketDisconnected()) {
    on<OnOpenEvent>(_onOpenWebSocket);
    on<OnMessageEvent>(_onMessageWebSocket);
    on<OnErrorEvent>(_onErrorWebSocket);
    on<OnClosedEvent>(_onClosedWebSocket);
    on<OnDisconnectEvent>(_disconnect);
  }

  late final StreamSubscription _connectionSubscription;
  WebSocketDelegate? _delegate;

  bool isConnected() {
    return state is! WebSocketDisconnected;
  }

  void connect(String info) {
    _delegate?.close();
    _delegate = WebSocketDelegate(info, onOpen: () {
      add(const OnOpenEvent());
    }, onMessage: (message) {
      add(OnMessageEvent(message));
    }, onError: (Object e) {
      add(OnErrorEvent(e as Exception));
    }, onClose: (code, reason) {
      add(OnClosedEvent(code, reason));
    });

    _delegate!.connect();
  }

  void _disconnect(OnDisconnectEvent event, Emitter<WebSocketState> emit) {
    _delegate?.close();
    emit(WebSocketDisconnected());
  }

  void dispose() {
    add(const OnDisconnectEvent());
    _connectionSubscription.cancel();
  }

  void _onOpenWebSocket(OnOpenEvent event, Emitter<WebSocketState> emit) {
    developer.log('Websocket connected');
    emit(WebSocketConnected());
  }

  void _onMessageWebSocket(OnMessageEvent event, Emitter<WebSocketState> emit) {
    developer.log('Websocket message: ${event.message}');
    final data = json.decode(event.message);
    if (data is Map<String, dynamic>) {
      if (data.containsKey('type')) {
        final command = data['type'];
        if (command == 'client_message') {
          final msg = WebSocketSendMessage.fromJson(data);
          emit(msg);
        } else if (command == 'client_shutdown') {
          final msg = WebSocketShutdown.fromJson();
          emit(msg);
        } else if (command == 'client_reset') {
          final msg = WebSocketReset.fromJson();
          emit(msg);
        }
      }
    }
  }

  void _onErrorWebSocket(OnErrorEvent event, Emitter<WebSocketState> emit) {
    final err = event.error.toString();
    developer.log('Websocket error: $err');
    final fail = WebSocketFailure.fromError(err);
    emit(fail);
  }

  void _onClosedWebSocket(OnClosedEvent event, Emitter<WebSocketState> emit) {
    developer.log('Websocket closed by server: ${event.reason} (code: ${event.code})');
    emit(WebSocketDisconnected());
  }
}
