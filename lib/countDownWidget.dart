import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownWidget extends StatefulWidget {
  final double size = 130;
  Function onTimeout = () {};
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  CountdownWidget(Function onTimeout) {
    this.onTimeout = onTimeout;
  }

  @override
  State<StatefulWidget> createState() {
    return _CountdownWidget();
  }
}

class _CountdownWidget extends State<CountdownWidget>
    with TickerProviderStateMixin {
  Timer? countdownTimer;
  Duration currentTimeout = Duration(seconds: 60);
  Duration originalTimeout = Duration(seconds: 60);
  bool isTimeout = false;
  StateSetter? _setState = null;

  _CountdownWidget() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  @override
  void initState() {
    widget.prefs.then((p) {
      int settingsTimeout = p.getInt('_totalTimeInSeconds') ?? 60;
      setState(() {
        currentTimeout = Duration(seconds: settingsTimeout);
        originalTimeout = Duration(seconds: settingsTimeout);
      });
    });
    super.initState();
  }

  void setCountDown() {
    if (!mounted) return;
    setState(() {
      if (currentTimeout.inSeconds <= 0) {
        widget.onTimeout();
        setState(() {
          isTimeout = true;
        });
      }

      currentTimeout = Duration(seconds: currentTimeout.inSeconds - 1);
      if (_setState != null) {
        _setState!(() {
          currentTimeout = currentTimeout;
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer!.cancel();
    countdownTimer = null;
    super.dispose();
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(currentTimeout.inSeconds.toString()),
          children: [
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              _setState = setState;
              return Text(currentTimeout.inSeconds.toString());
            })
          ],
        );
      },
    ).then((value) => _setState = null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      child: Stack(children: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber,
            ),
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: (currentTimeout.inSeconds) / originalTimeout.inSeconds,
              semanticsLabel: 'Circular progress indicator',
            ),
          ),
        ),
        Center(
          child: Text(currentTimeout.inSeconds.toString(),
              style: Theme.of(context).textTheme.headline3?.copyWith(
                  color: Colors.white, backgroundColor: Colors.amber)),
        )
      ]),
    );
  }
}
