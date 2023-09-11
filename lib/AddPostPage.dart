import 'package:flutter/material.dart';
import 'UserData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UserData.dart';

// FirebaseFirestore クラスを用いる際に必要
import 'package:cloud_firestore/cloud_firestore.dart';

// 投稿画面用Widget
class AddPostPage extends StatefulWidget {
  // ユーザー情報を取得する
  User user = UserData.getUser();
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 入力した投稿メッセージ
  String messageText = '';
  final _editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              TextFormField(
                controller: _editController,
                decoration: InputDecoration(labelText: '投稿メッセージ'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                onChanged: (String value) {
                  setState(() {
                    messageText = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('登録'),
                  onPressed: () async {

                    // 金額が無記述の場合は何もしない
                    if(messageText == '') {
                      // キーボードを閉じる
                      primaryFocus?.unfocus();
                      return;
                    }

                    final date = DateTime.now().toLocal().toIso8601String(); // 現在の日時
                    final email = widget.user.email; // AddPostPage のデータを参照

                    // 投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('posts') // コレクションID指定
                        .doc() // ドキュメントID自動生成
                        .set({
                      'text': messageText,
                      'email': email,
                      'date': date
                    });

                    // 金額を消す
                    _editController.clear();

                    // キーボードを閉じる
                    primaryFocus?.unfocus();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
