import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UserData.dart';

// チャット画面用Widget
class ChatPage extends StatelessWidget {
  // ユーザー情報を取得する
  final User user = UserData.getUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：${user.email}'),
          ),
          Expanded(
            // StreamBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  // 取得した投稿メッセージ一覧を元にリスト表示
                  return ListView(
                    children: documents.map((document) {
                      // 支払われたユーザーのUUIDをリストとして取得する
                      var _bepaidUUIDList = document['be-paid'] as List;
                      // validがtrueの時のみCardウィジェットを表示させる
                      return document['valid'] == true ? Card(
                        child: ListTile(
                          // 支払った品目名と金額
                          title: Text(document['item-name'].toString() + "：" + document['money'].toString()),
                          // 誰が誰に支払ったかの表示
                          subtitle: Text(
                              UserData.getUserNameFromEventUserUUID(document['payer']).toString()
                                  + ' ->'
                                  + _getBePaidUsers(_bepaidUUIDList)
                          ),
                          // 自分の投稿メッセージの場合はアーカイブボタンを表示
                          trailing: document['post-user'] == UserData.getUUID()
                              ? IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    // 投稿メッセージのドキュメントを非表示にする
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(document.id)
                                        .update({'valid': false});
                                  },
                                )
                              : null,
                        ),
                      )
                      // valid == falseの時はSizedBoxを表示する（表面上何も表示されない）
                      : SizedBox();
                    }).toList(),
                  );
                }
                // データが読込中の場合
                return Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 支払われたユーザー名を文字列にして返す関数
  String _getBePaidUsers(List userslist){
    // 支払われたユーザー数が全てのユーザー数と一致する場合
    if(userslist.length == UserData.getEventUserList().length) return " 全員";
    // それ以外の時
    String users = "";
    for(int i=0; i<userslist.length; i++){
      users += (" " + UserData.getUserNameFromEventUserUUID(userslist[i]));
    }
    return users;
  }
}
