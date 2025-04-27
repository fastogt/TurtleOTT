part of 'online_subscribers_bloc.dart';

abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => <Object?>[];
}

class SendMessageData extends BaseState {
  final NotificationTextInfo message;

  const SendMessageData(this.message);

  @override
  List<Object?> get props => <Object?>[message];
}

class ResetData extends BaseState {
  const ResetData();

  @override
  List<Object?> get props => <Object?>[];
}

class ShutDownData extends BaseState {
  const ShutDownData();

  @override
  List<Object?> get props => <Object?>[];
}

class InitialState extends BaseState {
  const InitialState();

  @override
  List<Object?> get props => <Object?>[];
}

class FailureState extends BaseState {
  final String description;

  const FailureState(this.description);

  @override
  List<Object?> get props => <Object?>[description];
}
