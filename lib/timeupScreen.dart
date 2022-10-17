import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pictionary/main.dart';
import 'package:pictionary/pictionaryScreen.dart';
import 'package:pictionary/welcomeScreen.dart';
import 'package:pictionary/wordsRepository.dart';
import 'dart:math';
import 'gameword.dart';

class TimeupScreen extends StatelessWidget {
  List<GameWords> words;
  WordsRepository wordsRepository = Global.wordsRepository;

  TimeupScreen(this.words);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //    crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Time's Up!",
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.copyWith(color: Colors.red)),
          getGridOfWords(context),
          SizedBox(
            width: 70,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PictionaryScreen()),
                  );
                },
                child: Text("New Game"),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
                child: Text("Menu"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getGridOfWords(BuildContext context) {
    return Center(
      child: Container(
        width: 150,
        height: 400,
        child: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: words.length,
            itemBuilder: (_, int index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    words[index].word,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }),
      ),
    );
  }
}
