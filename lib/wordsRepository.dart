import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'categoryData.dart';

abstract class WordsRepository {
  Future init();
  Future<List<CategoryData>> getAllCategories();
  Future<List<String>> getSelectedCategories();
  Future<List<String>> getWords({required String categoryName});
  Future saveSelectedCategories(List<String> categories);
}

class FileWordsRepository extends WordsRepository {
  bool isInitialized = false;
  final String SELECTED_CATEGORIES = "SELECTED_CATEGORIES";

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final Map<String, List<String>> _map = Map();
  final List<CategoryData> _categoryData = [
    // CategoryData("Movies", Icons.movie, "films.txt"),
    CategoryData("General", Icons.question_answer, "pictionary_words.csv")
  ];

  Future init() {
    List<Future> futures = [];
    if (!isInitialized) {
      futures = _categoryData.map((category) {
        return _loadAsset(category.title, category.resourceName);
      }).toList();
      futures.add(saveSelectedCategories(["General"]));
    }
    return Future.wait(futures).then((value) => isInitialized = true);
  }

  Future<List<CategoryData>> getAllCategories() {
    return Future.value(_categoryData);
  }

  Future<List<String>> getWords({required String categoryName}) {
    return Future.value(_map[categoryName] ?? []);
  }

  @override
  Future<List<String>> getSelectedCategories() {
    return _prefs.then((SharedPreferences prefs) {
      return prefs.getStringList(SELECTED_CATEGORIES) ?? [];
    });
  }

  @override
  Future saveSelectedCategories(List<String> categories) {
    return _prefs.then((SharedPreferences prefs) {
      return prefs.setStringList(SELECTED_CATEGORIES, categories);
    });
  }

  Future _loadAsset(String categoryName, String resourceName) {
    return rootBundle
        .loadString('assets/data/${resourceName}')
        .then((fileContent) {
      _map[categoryName] = fileContent.split("\n");
    });
  }
}

class Global {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();
  static bool _enableTimer = true;

  static bool get enableTimer {
    return _enableTimer;
  }

  static set enableTimer(bool useTimer) {
    _enableTimer = useTimer;
    _prefs.then((value) => _enableTimer = useTimer);
  }

  static final instance = Global();
  static final WordsRepository wordsRepository = FileWordsRepository();
  Global() {
    Global.wordsRepository.init();
  }
}
