import 'package:flutter/material.dart';
import 'package:otel_ve_emlak_kiralama/models/user_objects.dart';

class AppConstants {
  static final String appName= 'Otel ve Emlak Kiralama';
  static final String googleMapsKey= 'AIzaSyCyFwBZiPweJtpr1pmmywGVU2UnuIsso8Y';

  static UserModel currentUser= UserModel();

  static final Color selectedIcon= Colors.white;
  static final Color nonselectedIcon= Colors.grey;


  static final Map<int,String> monthsDictionaryMap = {
    1: "Ocak",
    2: "Şubat",
    3: "Mart",
    4: "Nisan",
    5: "Mayıs",
    6: "Haziran",
    7: "Temmuz",
    8: "Ağustos",
    9: "Eylül",
    10: "Ekim",
    11: "Kasım",
    12: "Aralık",
  };

  static final Map<int,int> daysInMonthsMap = {
    1: 31,
    2: DateTime.now().year % 4 == 0 ? 29 : 28,
    3: 31,
    4: 30,
    5: 31,
    6: 30,
    7: 31,
    8: 31,
    9: 30,
    10: 31,
    11: 30,
    12: 31,
  };
}