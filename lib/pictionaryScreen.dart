import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pictionary/wordsRepository.dart';
import 'countDownWidget.dart';
import 'gameword.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PictionaryScreen extends StatefulWidget {
  final _random = Random();

  @override
  State<StatefulWidget> createState() {
    return _PictionaryScreen();
  }
}

class _PictionaryScreen extends State<PictionaryScreen> {
  List<GameWords> words = [];
  List<GameWords> usedWords = [];

  int _wordIndex = 0;
  bool isGameOver = false;

  @override
  void initState() {
    _loadWords();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // toolbarHeight: 400,
          centerTitle: true,
          title: Global.enableTimer
              ? Center(
                  child: createCountDownWidget(context),
                )
              : SizedBox(
                  height: 10,
                  width: 80,
                ),
        ),
        body: ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: usedWords.length,
            itemBuilder: (_, int index) {
              return Center(
                child: GestureDetector(
                  onTap: isGameOver ? () {} : getNewWord,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        index == 0
                            ? words[_wordIndex].word
                            : usedWords[index].word,
                        style: index == 0
                            ? Theme.of(context).textTheme.headline1
                            : Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  CountdownWidget createCountDownWidget(BuildContext context) {
    return CountdownWidget(() {
      if (!mounted) return;

      setState(() {
        isGameOver = true;
      });
    });
  }

  void getNewWord() {
    setState(() {
      if (isGameOver) {
        isGameOver = false;
      }
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      setState(() {
        _wordIndex = widget._random.nextInt(words.length);
      });

      usedWords = [words[_wordIndex]] + usedWords;
    });
  }

  void _loadWords() async {
    var categories = await Global.wordsRepository.getSelectedCategories();
    categories.forEach((category) async {
      var categoryWords =
          await Global.wordsRepository.getWords(categoryName: category);

      setState(() {
        words.addAll(categoryWords.map((w) => GameWords(w)));
        words = words.toList();
        _wordIndex = widget._random.nextInt(words.length);
        usedWords = usedWords + [words[_wordIndex]];
      });
    });
  }
}
