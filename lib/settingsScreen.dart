import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pictionary/wordsRepository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';

import 'categoryData.dart';

class SettingsScreen extends StatefulWidget {
  late WordsRepository _wordsRepository = Global.wordsRepository;
  @override
  State<StatefulWidget> createState() {
    return _SettingsScreen();
  }
}

class _SettingsScreen extends State<SettingsScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late int _seconds = 60;
  late bool _enableTimer = Global.enableTimer;
  List<CategoryData> item = [];

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        _seconds = prefs.getInt('_totalTimeInSeconds') ?? 60;
      });
    });

    widget._wordsRepository
        .getAllCategories()
        .then((newWordsList) => setState(() {
              item = newWordsList;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(
              'Common',
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text('English'),
                trailing: Icon(Icons.navigate_next),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    _enableTimer = !_enableTimer;
                  });
                  Global.enableTimer = _enableTimer;
                },
                initialValue: Global.enableTimer,
                // enabled: _enableTimer,
                leading: Icon(Icons.timer),
                title: Text('Enable timer'),
              ),
              SettingsTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_formatedTime(_seconds)),
                    Slider(
                      value: _seconds.toDouble(),
                      max: 60 * 5,
                      min: 5,
                      label: _seconds.toString(),
                      onChanged: _enableTimer ? updateSecondsTimeout : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // SettingsSection(
          //   title: Text(
          //     'Categories',
          //     style: TextStyle(color: Colors.black),
          //   ),
          //   tiles: <SettingsTile>[
          //     SettingsTile(
          //       title: SizedBox(
          //         height: 300,
          //         child: GridView.builder(
          //             gridDelegate:
          //                 const SliverGridDelegateWithMaxCrossAxisExtent(
          //                     maxCrossAxisExtent: 150,
          //                     //    childAspectRatio: 3 / 2,
          //                     crossAxisSpacing: 20,
          //                     mainAxisSpacing: 20),
          //             itemCount: item.length,
          //             itemBuilder: (BuildContext ctx, index) {
          //               return createCard(item[index]);
          //             }),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  String _formatedTime(int timeInSecond) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  void updateSecondsTimeout(double value) {
    _prefs.then((SharedPreferences prefs) {
      prefs.setInt('_totalTimeInSeconds', value.toInt());
    });
    setState(() {
      _seconds = value.toInt();
    });
  }

  Widget createCard(CategoryData categoryData) {
    return GestureDetector(
      onTap: () {
        categoryData.isSelected = !categoryData.isSelected;
        setState(() {
          item = item.toList();
        });
        widget._wordsRepository.saveSelectedCategories(
            item.where((c) => c.isSelected).map((w) => w.title).toList());
      },
      child: Card(
        shape: categoryData.isSelected
            ? new RoundedRectangleBorder(
                side: new BorderSide(color: Colors.blue, width: 2.0),
                borderRadius: BorderRadius.circular(4.0))
            : new RoundedRectangleBorder(
                side: new BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(4.0)),
        child: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(categoryData.icon),
              new Text('${categoryData.title}'),
            ],
          ),
        ),
      ),
    );
  }
}
