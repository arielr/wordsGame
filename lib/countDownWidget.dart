import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownWidget extends StatefulWidget {
  final double size = 60;
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

  _CountdownWidget() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  @override
  void initState() {
    widget.prefs.then((p) {
      int settingsTimeout = p.getInt('_totalTimeInSeconds') ?? 60;
      currentTimeout = Duration(seconds: settingsTimeout);
      originalTimeout = Duration(seconds: settingsTimeout);
    });
    super.initState();
  }

  void setCountDown() {
    if (!mounted) return;
    setState(() {
      final seconds = currentTimeout.inSeconds - 1;
      if (seconds < 0) {
        widget.onTimeout();
        setState(() {
          isTimeout = true;
        });
      }

      currentTimeout = Duration(seconds: seconds);
    });
  }

  @override
  void dispose() {
    countdownTimer!.cancel();
    countdownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _dialogBuilder(context),
      child: Container(
        child: Text(
          currentTimeout.inSeconds.toString(),
          style: isTimeout
              ? Theme.of(context).textTheme.bodyText1?.apply(color: Colors.red)
              : Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ss'),
          content: Text("Pause time"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// @override
  // Widget build(BuildContext context) {
  //   return SizedBox(
  //     height: widget.size,
  //     child: Stack(children: [
  //       Center(
  //         child: Container(
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: Colors.amber,
  //           ),
  //           width: widget.size,
  //           height: widget.size,
  //           child: CircularProgressIndicator(
  //             value: (currentTimeout.inSeconds) / originalTimeout.inSeconds,
  //             semanticsLabel: 'Circular progress indicator',
  //           ),
  //         ),
  //       ),
  //       Center(
  //         child: Text(currentTimeout.inSeconds.toString(),
  //             style: Theme.of(context).textTheme.headline5?.copyWith(
  //                 color: Colors.white, backgroundColor: Colors.amber)),
  //       )
  //     ]),
  //   );
  // }
}
