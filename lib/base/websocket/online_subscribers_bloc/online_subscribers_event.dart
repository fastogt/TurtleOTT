part of 'online_subscribers_bloc.dart';

abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ListenEvent extends BaseEvent {
  const ListenEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class InitialEvent extends BaseEvent {
  const InitialEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadEvent extends BaseEvent {
  const LoadEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AddEvent extends BaseEvent {
  final Map<String, dynamic> data;

  const AddEvent(this.data);

  @override
  List<Object?> get props => <Object?>[data];
}

class ShutDownEvent extends BaseEvent {
  const ShutDownEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class ResetEvent extends BaseEvent {
  const ResetEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class FailureEvent extends BaseEvent {
  final String description;

  const FailureEvent(this.description);

  @override
  List<Object?> get props => <Object?>[description];
}
