import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:pictionary/wordsRepository.dart';
import 'package:sliver_tools/sliver_tools.dart';
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
  Widget? countDown;
  int _wordIndex = 0;
  bool isGameOver = false;

  @override
  void initState() {
    _loadWords();
    setState(() {
      countDown = CountdownWidget(onGameOver);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("Pictionary"),
        ),
        // backgroundColor: Color.fromARGB(0xff, 0xff, 0xcd, 0x3c),
        body: SafeArea(
            //bottom, top, left and right are true by default so no need to add them
            child: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
          MultiSliver(
            // defaults to false
            pushPinnedChildren: false,
            children: <Widget>[
              SliverPinnedHeader(
                  child: Center(
                child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    height: screenHeight / 4,
                    child: Center(child: countDown)),
              )),
              SliverPinnedHeader(
                  child: GestureDetector(
                onTap: isGameOver ? () {} : getNewWord,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  height: screenHeight / 3,
                  child: isGameOver
                      ? Center(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Time's up!",
                                    style:
                                        Theme.of(context).textTheme.headline2),
                                SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PictionaryScreen()),
                                      );
                                    },
                                    child: Text("Start new game"))
                              ],
                            ),
                          ),
                        )
                      : createCard(
                          words[_wordIndex].word,
                          Theme.of(context)
                              .textTheme
                              .headline2
                              ?.apply(fontWeightDelta: 4)),
                ),
              )),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: createCard(usedWords[index].word,
                              Theme.of(context).textTheme.headline4),
                        ));
                  },
                  // 40 list items
                  childCount: usedWords.length,
                ),
              ),
            ],
          )
        ])));
  }

  onGameOver() {
    setState(() {
      if (!isGameOver) {
        usedWords.add(words[_wordIndex]);
        usedWords = usedWords.toList();
      }
      isGameOver = true;
    });
  }

  Widget createCard(String word, TextStyle? style) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Center(
        child: Text(
          word,
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Widget getOldList() {
  //   return ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: usedWords.length,
  //       itemBuilder: (_, int index) {
  //         return GestureDetector(
  //           onTap: isGameOver ? () {} : getNewWord,
  //           child: Center(
  //             child: Card(
  //               color: Theme.of(context).scaffoldBackgroundColor,
  //               child: FittedBox(
  //                 fit: BoxFit.scaleDown,
  //                 child: Center(
  //                   child: Text(
  //                     index == 0
  //                         ? words[_wordIndex].word
  //                         : usedWords[index].word,
  //                     style: index == 0
  //                         ? Theme.of(context).textTheme.headline1
  //                         : Theme.of(context).textTheme.headline4,
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }

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
        usedWords = [words[_wordIndex]] + usedWords;
        _wordIndex = widget._random.nextInt(words.length);
      });
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
      });
    });
  }
}
