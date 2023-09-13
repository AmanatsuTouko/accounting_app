import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserData.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード・ユーザーネーム
  // メールアドレス・パスワードはfirebaseのAuthで登録時に用いる
  // メールアドレス・ユーザーネームはfirestoreにユーザー情報を保存しておく
  String email = '';
  String password = '';
  String username = '';

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
              // パスワード入力
              TextFormField(
                decoration: InputDecoration(labelText: 'ユーザーネーム'),
                onChanged: (String value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),

              // ユーザー登録
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('ユーザー登録'),
                  onPressed: _onTapRegisterButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapRegisterButton() async {

    // メール, パスワード, ユーザー名のいずれかが未記入の際に弾く
    if(email == '' || password == '' || username=='') {
      infoText = "メールアドレス, パスワード, ユーザーネームのいずれかが未記入です。";
      return;
    }

    try {
      // メール/パスワードでユーザー登録
      final FirebaseAuth auth = FirebaseAuth.instance;
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ユーザー登録に成功した場合
      // ユーザーデータの保存
      await UserData.setUserData(user: result.user!);

      // firestoreのuserコレクションにユーザーデータを保存する
      await FirebaseFirestore.instance
          .collection('users') // コレクションID指定
          .doc() // ドキュメントID自動生成
          .set({
        'email': email,
        'username': username,
      });

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
      // ユーザー登録に失敗した場合
      setState(() {
        infoText = "登録に失敗しました：${e.toString()}";
      });
    }
  }
}
