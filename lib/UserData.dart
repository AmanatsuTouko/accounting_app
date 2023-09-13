import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// グローバルにFireBaseに用いたデータを管理するため、staticなクラスを定義する
// firebaseのAuthに接続するためのUserインスタンスを保存するためのクラス
class UserData {
  // クライアントにログインしているユーザーのデータ
  static late User _user;
  static late String _uuid;
  // firestoreから取得した全ユーザーのデータ
  static late List<EventUser> _eventUserList = [];
  static late Map<String, String> _eventUser_UUIDUserNamePares = {};


  static Future setUserData({required User user}) async {
    UserData._user = user;
  }
  static User getUser() {
    return UserData._user;
  }

  static Future setUUID({required String uuid}) async {
    UserData._uuid = uuid;
  }
  static String getUUID(){
    return UserData._uuid;
  }

  // firestoreの他のユーザーを再登録する際に、一度すべて削除できるようにする
  static Future deleteEventUser() async {
    UserData._eventUserList.clear();
    UserData._eventUser_UUIDUserNamePares.clear();
  }
  // firestoreの他のユーザーを追加するs
  static Future addEventUser({required EventUser eventUser}) async {
    await UserData.deleteEventUser();
    // Listに追加する
    UserData._eventUserList.add(eventUser);
    // uuidからusernameを後で参照できるように辞書登録する
    UserData._eventUser_UUIDUserNamePares[eventUser.id] = eventUser.username;
  }
  // firestoreの他のユーザーをuuidを入力として、usernameを返す関数
  static String getUserNameFromEventUserUUID(String uuid){
    String? username = UserData._eventUser_UUIDUserNamePares[uuid];
    if(username != null) return username;
    else return "ERROR";
  }
  static List<EventUser> getEventUserList(){
    return _eventUserList;
  }
}

// firestoreの他のユーザーデータを保存するためのクラス
class EventUser{
  String id;
  String email;
  String username;

  EventUser(this.id, this.email, this.username);
}