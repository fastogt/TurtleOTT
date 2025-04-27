import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fastotv_dart/commands_info/notification_text_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turtleott/base/websocket/websocket_api_bloc/websocket_api_bloc.dart';

part 'online_subscribers_event.dart';
part 'online_subscribers_state.dart';

class RealtimeMessageBloc extends Bloc<BaseEvent, BaseState> {
  RealtimeMessageBloc(this.webSocketApiBloc) : super(const InitialState()) {
    on<LoadEvent>(_load);
    on<ListenEvent>(_listen);
    on<InitialEvent>(_init);
    on<AddEvent>(_addMessage);
    on<ShutDownEvent>(_onShutDown);
    on<ResetEvent>(_onReset);
    add(const ListenEvent());
  }

  late final StreamSubscription _subscription;

  final WebSocketApiBloc webSocketApiBloc;

  void dispose() {
    _subscription.cancel();
  }

  void _init(InitialEvent event, Emitter<BaseState> emit) {
    emit(const InitialState());
  }

  void _listen(ListenEvent event, Emitter<BaseState> emit) {
    _subscription = webSocketApiBloc.stream.listen((WebSocketState event) {
      if (event is WebSocketSendMessage) {
        add(AddEvent(event.data));
      } else if (event is WebSocketShutdown) {
        kIsWeb ? add(const ResetEvent()) : add(const ShutDownEvent());
      } else if (event is WebSocketReset) {
        add(const ResetEvent());
      } else if (event is WebSocketFailure) {
        add(FailureEvent(event.description));
      } else if (event is WebSocketConnected) {
        add(const LoadEvent());
      }
    });
    if (webSocketApiBloc.isConnected()) {
      add(const LoadEvent());
    }
  }

  void _addMessage(AddEvent event, Emitter<BaseState> emit) {
    emit(const InitialState());
    final NotificationTextInfo msg = NotificationTextInfo.fromJson(event.data);
    emit(SendMessageData(msg));
  }

  void _onShutDown(ShutDownEvent event, Emitter<BaseState> emit) {
    emit(const InitialState());
    SystemNavigator.pop();
    emit(const ShutDownData());
  }

  Future<void> _onReset(ResetEvent event, Emitter<BaseState> emit) async {
    emit(const ResetData());
  }

  void _load(LoadEvent event, Emitter<BaseState> emit) async {}
}
