part of 'content_bloc.dart';

abstract class ContentState {}

class ContentStatedState extends ContentState {}

class LoadContentState extends ContentState {}

class SetContentSuccessState extends ContentState {}

class ParseContentState extends ContentState {
  int cur;
  int total;

  ParseContentState(this.cur, this.total);
}
