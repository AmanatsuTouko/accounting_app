import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UserData.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレス入力
              TextFormField(
                decoration: InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),

              // ログインボタン
              Container(
                width: double.infinity,
                child: OutlinedButton(
                  child: Text('ログイン'),
                  onPressed: _onTapLoginButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapLoginButton() async {
    try {
      // メール/パスワードでログイン
      final FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ログインに成功した場合
      // ユーザーデータの保存
      await UserData.setUserData(user: result.user!);

      // Userデータをstaticに取得できるように保存しておく
      final currentUser = await FirebaseAuth.instance.currentUser;
      if(currentUser != null) await UserData.setUserData(user: currentUser);
      // firestoreにあるusersコレクションを取得してローカルに保存しておく
      await FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          // デバッグ用に全ユーザーのデータを出力する
          print(doc.id); print(doc["email"]); print(doc["username"]);
          // 自身のuuidを取得して保存しておく
          if(currentUser!=null && doc["email"] == currentUser.email){
            UserData.setUUID(uuid: doc.id);
          }
          // 後で参照できるようにイベントスペースの参加者データを保存しておく
          await UserData.addEventUser(eventUser: new EventUser(doc.id, doc["email"], doc["username"]));
        });
      });

      // チャット画面に遷移＋ログイン画面を破棄
      await Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      // ログインに失敗した場合
      setState(() {
        infoText = "ログインに失敗しました：${e.toString()}";
      });
    }
  }
}
