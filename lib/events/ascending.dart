class ClientCatchupRequestEvent {
  final String id;
  final int start;
  final int end;
  final String title;

  ClientCatchupRequestEvent(this.id, this.start, this.end, this.title);
}

class ClientCatchupRequestUndoEvent {
  final String id;

  ClientCatchupRequestUndoEvent(this.id);
}
