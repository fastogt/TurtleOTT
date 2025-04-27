import 'dart:async';

import 'package:fastotv_dart/commands_info/notification_text_info.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationDialog extends StatefulWidget {
  final NotificationTextInfo notification;

  const NotificationDialog(this.notification);

  @override
  _NotificationDialogState createState() {
    return _NotificationDialogState();
  }
}

class _NotificationDialogState extends State<NotificationDialog> {
  NotificationTextInfo get _notification => widget.notification;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    final _seconds = widget.notification.showTime ~/ 1000;
    _timer = Timer(Duration(seconds: _seconds), () {
      _close();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = _notification.type == NotificationType.TEXT
        ? Text(_notification.message)
        : _link(_notification.message);
    return WillPopScope(
        onWillPop: () async {
          return !_timer.isActive;
        },
        child: AlertDialog(title: const Text('Notification'), content: content));
  }

  Widget _link(String link) {
    return InkWell(
        child: Text(link),
        onTap: () {
          _timer.cancel();
          _close();
          launch(link);
        });
  }

  void _close() {
    Navigator.of(context).pop();
  }
}
