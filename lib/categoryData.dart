import 'package:flutter/cupertino.dart';

class CategoryData {
  bool isSelected = true;
  String title;
  String resourceName;
  IconData icon;
  CategoryData(this.title, this.icon, this.resourceName);
}
