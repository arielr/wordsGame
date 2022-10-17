import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pictionary/pictionaryScreen.dart';
import 'package:pictionary/settingsScreen.dart';
import 'package:pictionary/wordsRepository.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
        style: style,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PictionaryScreen()),
          );
        },
        child: Text("New Game"),
      ),
      SizedBox(
        height: 20,
      ),
      ElevatedButton(
        style: style,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsScreen()),
          );
        },
        child: Text("Settings"),
      ),
      Container(
        color: Colors.red,
      )
    ]));
  }
}
