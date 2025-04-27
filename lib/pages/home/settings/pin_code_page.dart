import 'package:flutter/material.dart';
import 'package:turtleott/base/animated_counter.dart';
import 'package:turtleott/base/round_button.dart';
import 'package:turtleott/base/streams_grid/grid.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({Key? key}) : super(key: key);

  @override
  _PinCodePageState createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Row(children: [
        Padding(
            padding: EdgeInsets.all(TvStreamsGrid.BASE_PADDING.top),
            child: RoundedButton(icon: Icons.arrow_back, onTap: Navigator.of(context).pop))
      ]),
      const Spacer(),
      Text('PIN', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black)),
      SizedBox(height: TvStreamsGrid.BASE_PADDING.top / 2),
      FractionallySizedBox(
          widthFactor: 0.7, child: Image.asset('install/assets/rainbow_hor.jpg', fit: BoxFit.fill)),
      Padding(
          padding: EdgeInsets.all(TvStreamsGrid.BASE_PADDING.top),
          child: const Text('Enter PIN code', style: TextStyle(fontSize: 20))),
      PinCodeField(onChanged: (value) {}),
      const Spacer()
    ]));
  }
}

class PinCodeField extends StatelessWidget {
  PinCodeField({required this.onChanged, this.digits = 4, Key? key}) : super(key: key);

  final int digits;
  final void Function(String? value) onChanged;
  final List<int?> _result = <int?>[null, null, null, null];

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(4, (index) {
          return AnimatedCounter(onChanged: (value) {
            _result[index] = value;
            onChanged(makeString());
          });
        }));
  }

  String makeString() {
    final StringBuffer _string = StringBuffer();
    for (final int? number in _result) {
      if (number != null) {
        _string.write(number.toString());
      }
    }
    return _string.toString();
  }
}
