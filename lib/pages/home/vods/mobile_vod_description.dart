import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/vods/vod_description.dart';
import 'package:intl/intl.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/base/locked_dialog.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/vods/player/vod_player.dart';
import 'package:turtleott/pages/mobile/vods/vod_player_page.dart';
import 'package:turtleott/pages/mobile/vods/vod_trailer_page.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/service_locator.dart';

class SideInfo extends StatelessWidget {
  final int duration;
  final int primeDate;
  final String? country;
  final double? fontSize;
  final int? views;
  final ScrollController? scrollController;

  const SideInfo(
      {this.country,
      required this.duration,
      required this.primeDate,
      this.views,
      this.fontSize,
      this.scrollController});

  @override
  Widget build(BuildContext context) {
    final ts = DateTime.fromMillisecondsSinceEpoch(primeDate);
    final date = DateFormat('dd.MM yyyy').format(ts);
    final List<Widget> info = [
      _sideDescription(translate(context, TR_COUNTRY), data: country),
      _sideDescription(translate(context, TR_DURATION), data: _getDuration(duration)),
      _sideDescription(translate(context, TR_PRIME_DATE), data: date),
      _sideDescription(translate(context, TR_VIEWS), data: views.toString())
    ];
    return SingleChildScrollView(
        controller: scrollController ?? ScrollController(),
        scrollDirection: Axis.horizontal,
        child: Row(children: info));
  }

  // private:
  String _getDuration(int msec) {
    final now = DateTime.now();
    return hmFromMsec(msec - now.timeZoneOffset.inMilliseconds);
  }

  Widget _sideDescription(String title, {String? data}) {
    return SideInfoItem(title: title, data: data ?? '');
  }
}

class VodTrailerButton extends StatelessWidget {
  final VodInfo vod;
  final FocusNode? focus;

  const VodTrailerButton(this.vod, {this.focus});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        focusNode: focus,
        style: OutlinedButton.styleFrom(
            shape: StadiumBorder(
                side: BorderSide(width: 2, color: Theme.of(context).colorScheme.secondary))),
        child: FittedBox(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(translate(context, TR_TRAILER))])),
        onPressed: () {
          return _onTrailer(context);
        });
  }

  // private:
  void _onTrailer(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VodTrailer(
          "${translate(context, TR_TRAILER)}: ${AppLocalizations.toUtf8(vod.displayName())}",
          vod.trailerUrl(),
          vod.icon());
    }));
  }
}

class TvVodTrailerButton extends StatelessWidget {
  final VodInfo vod;
  final FocusNode? focus;

  const TvVodTrailerButton(this.vod, {this.focus});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        focusNode: focus,
        style: OutlinedButton.styleFrom(
            shape: StadiumBorder(
                side: BorderSide(width: 2, color: Theme.of(context).colorScheme.secondary))),
        child: FittedBox(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(translate(context, TR_TRAILER))])),
        onPressed: () {
          return _onTrailer(context, vod);
        });
  }

  void _onTrailer(BuildContext context, VodInfo vod) {
    final vodStream = VodStream(vod);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VodTrailerPlayer(vodStream);
    }));
  }
}

class BaseVodPlayButton extends StatelessWidget {
  final FocusNode? focus;
  final OttPackageInfo package;
  final VodInfo vod;
  final bool locked;
  final IPlayerListener listener;
  final void Function()? onTap;
  final VoidCallback onPackageBuyPressed;

  const BaseVodPlayButton(
      this.vod, this.package, this.locked, this.listener, this.onPackageBuyPressed,
      {this.onTap, this.focus});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        focusNode: focus,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        child: FittedBox(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(translate(context, TR_PLAY)),
          if (locked) const Icon(Icons.lock) else const Icon(Icons.play_arrow)
        ])),
        onPressed: () {
          _onTapped(context, vod);
        });
  }

  void _onTapped(BuildContext context, VodInfo vod) async {
    final vodStream = VodStream(vod);
    final device = locator<RuntimeDevice>();

    if (!locked) {
      if (onTap != null) {
        onTap?.call();
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MobileVodPlayer(vodStream, listener);
        }));
      }
    } else {
      final price = package.price!;
      showDialog(
          context: context,
          builder: (context) => LockedPackageDialog(
                onPackageBuyPressed,
                price.price,
                price.currency,
                isTV: !device.hasTouch,
              ));
    }
  }
}

class DescriptionText extends StatelessWidget {
  final String text;
  final ScrollController? scrollController;
  final double? textSize;
  final Color? textColor;

  const DescriptionText(this.text, {this.scrollController, this.textColor, this.textSize});

  @override
  Widget build(BuildContext context) {
    return text.isEmpty
        ? Center(
            child: NonAvailableBuffer(
            message: translate(context, TR_NO_DESCRIPTION),
            color: textColor,
            icon: Icons.description,
          ))
        : SingleChildScrollView(
            controller: scrollController ?? ScrollController(),
            padding: const EdgeInsets.all(16.0),
            child: Text(text, style: TextStyle(fontSize: textSize ?? 16, color: textColor)));
  }
}

class UserScore extends StatelessWidget {
  final double score;
  final double fontSize;

  const UserScore(this.score, {this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    Widget circleIndicator(double score) {
      return Center(
          child: CustomPaint(
              foregroundPainter:
                  CircleProgress(score, context), // this will add custom painter after child
              child: SizedBox(
                  width: fontSize * 4,
                  height: fontSize * 4,
                  child: Center(
                      child: Text(score.toStringAsFixed(1),
                          style: TextStyle(fontSize: fontSize / 3 * 4))))));
    }

    return Row(children: <Widget>[
      Text(translate(context, TR_RAITING),
          style: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      circleIndicator(score)
    ]);
  }
}
