import 'package:flutter/material.dart';
import 'package:turtleott/base/animated_list_section.dart';
import 'package:turtleott/pages/home/settings/pin_code_page.dart';

class ParentalControlPage extends StatelessWidget {
  const ParentalControlPage();

  @override
  Widget build(BuildContext context) {
    return AnimatedListSection<String>(
        items: const ['Change restriction', 'Change pin-code'],
        itemBuilder: (String section) => Text(section),
        onItem: (value) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const PinCodePage();
          }));
        },
        contentBuilder: (category) => const SizedBox());
  }
}
