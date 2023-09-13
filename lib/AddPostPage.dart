import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _inputMoney = 0;
  final _editController = TextEditingController();

  // Userを取得してリストに置いておく
  List<EventUser> _eventUserList = UserData.getEventUserList();
  // 支払ったユーザーとして、何番目のユーザーを選択したかのindex
  int _payerUserIndex = -1;

  bool _isChecked = false;
  // List<bool> _isBepaidUserList = []..length = UserData.getEventUserList().length;
  final List<bool> _isBepaidUserList = List.generate(
      UserData.getEventUserList().length, (bool) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("支払った人"),
              for(int i=0; i<_eventUserList.length; i++)...{
                Row(
                  children: [
                    Radio(
                      value: i,
                      groupValue: _payerUserIndex,
                      onChanged: (value) {
                        setState(() {
                          _payerUserIndex = value!;
                        });
                      }),
                    Text(_eventUserList[i].username),
                  ],
                ),
              },

              Text("支払われた人"),
              for(int i=0; i<_eventUserList.length; i++)...{
                Row(
                  children: [
                    Checkbox(
                      value: _isBepaidUserList[i],
                      onChanged: (value) {
                        setState(() {
                          // check状態を反転させる
                          _isBepaidUserList[i] = !_isBepaidUserList[i];
                        });
                      },
                    ),
                    Text(_eventUserList[i].username),
                  ],
                ),
              },

              // 投稿メッセージ入力
              TextFormField(
                controller: _editController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: '金額'),
                // 複数行のテキスト入力
                onChanged: (String value) {
                  setState(() {
                    _inputMoney = int.parse(value);
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('登録'),
                  onPressed: _onPressedRegisterButton,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onPressedRegisterButton() async {
    // 金額が無記述の場合は何もしない
    if(_inputMoney == 0) {
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
      'money': _inputMoney,
      'email': email,
      'date': date,
    });

    // 金額を消す
    _editController.clear();

    // キーボードを閉じる
    primaryFocus?.unfocus();
  }
}
