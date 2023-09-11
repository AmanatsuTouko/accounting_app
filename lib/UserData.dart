import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// グローバルにFireBaseに用いたデータを管理するため、staticなクラスを定義する
class UserData {
  static late User _user;

  static Future setUserData({required User user}) async {
    UserData._user = user;
  }

  static User getUser() {
    return UserData._user;
  }
}
