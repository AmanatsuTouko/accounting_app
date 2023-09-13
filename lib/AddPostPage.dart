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
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // 入力した投稿メッセージ
  String _inputItemText = '';
  int _inputMoney = 0;
  final _editControllerItemText = TextEditingController();
  final _editControllerMoney = TextEditingController();

  // Userを取得してリストに置いておく
  List<EventUser> _eventUserList = UserData.getEventUserList();
  // 支払ったユーザーとして、何番目のユーザーを選択したかのindex
  int _payerUserIndex = -1;
  // 支払われたユーザーがチェックされた時に保存しておくList
  final List<bool> _isBepaidUserList = List.generate(
      UserData.getEventUserList().length, (bool) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
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

                  // 品目の入力
                  TextFormField(
                    controller: _editControllerItemText,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: '品目'),
                    onChanged: (String value) {
                      setState(() {
                        _inputItemText = value;
                      });
                    },
                  ),

                  // 金額の入力
                  TextFormField(
                    controller: _editControllerMoney,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: '金額'),
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
            // mainAxisAlignment: MainAxisAlignment.center,

          ),
        ),
      ),
    );
  }

  void _onPressedRegisterButton() async {
    // 金額 or 品目が無記述の場合は何もしない
    if(_inputMoney == 0 || _inputItemText == '') {
      // キーボードを閉じる
      primaryFocus?.unfocus();
      return;
    }
    // 支払ったユーザーが未選択の場合は何もしない
    if(_payerUserIndex == -1) return;
    // 支払われたユーザーが未選択の場合も何もしない
    bool isExistBepaid = false;
    for(int i=0; i<_isBepaidUserList.length; i++){
      if(_isBepaidUserList[i] == true) {
        isExistBepaid = true;
        break;
       }
    }
    if(!isExistBepaid) return;

    final _date = DateTime.now().toLocal().toIso8601String(); // 現在の日時
    final _postuser = UserData.getUUID(); // 自身のUUID

    // 支払われたユーザーのidを纏めたリストを作成する
    List<String> _bepaidUserUUIDs = [];
    for(int i=0; i<_isBepaidUserList.length; i++){
      if(_isBepaidUserList[i] == true) _bepaidUserUUIDs.add(_eventUserList[i].id);
    }

    // firestoreへの投稿ドキュメント作成
    await FirebaseFirestore.instance
        .collection('posts') // コレクションID指定
        .doc() // ドキュメントID自動生成
        .set({
      'valid': true,
      'payer': _eventUserList[_payerUserIndex].id,
      'be-paid': _bepaidUserUUIDs,
      'money': _inputMoney,
      'item-name': _inputItemText,
      'post-user': _postuser,
      'date': _date,
    });

    // 画面の再描画
    setState(() {
      // 金額・品目名を消す
      _editControllerItemText.clear();
      _editControllerMoney.clear();
      // 支払った人(radio button)をリセットする
      _payerUserIndex = -1;
      // 支払われた人(checkbox)をリセットする
      for(int i=0; i<_isBepaidUserList.length; i++){
        _isBepaidUserList[i] = false;
      }
    });

    // キーボードを閉じる
    primaryFocus?.unfocus();
  }
}
