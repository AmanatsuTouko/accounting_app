import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// グローバルにFireBaseに用いたデータを管理するため、staticなクラスを定義する
class UserData {
  static late String _email;
  static late String _password;
  static late User _user;

  static Future setUserData(
      {required String email,
      required String password,
      required User user}) async {
    if (email == '' || password == '') {
      debugPrint("Error : setUserData method. Set email and password.");
      return;
    }
    // 値の代入
    UserData._email = email;
    UserData._password = password;
    UserData._user = user;
  }

  static User getUser() {
    if (UserData._email == '' || UserData._password == '') {
      debugPrint(
          "Error : getUserData method. user is not defined. Set email and password.");
    }
    return UserData._user;
  }
}
