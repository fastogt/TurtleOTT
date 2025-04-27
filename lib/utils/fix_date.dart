String fixZero(int number) {
  final StringBuffer _result = StringBuffer();
  if (number < 10) {
    _result.write(0);
  }
  _result.write(number);
  return _result.toString();
}
