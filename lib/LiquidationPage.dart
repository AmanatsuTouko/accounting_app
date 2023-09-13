import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'UserData.dart';

// 清算画面用ウィジェット
class LiquidationPage extends StatefulWidget {
  LiquidationPage({Key, key}) : super(key: key);

  @override
  _LiquidationPageState createState() => _LiquidationPageState();
}

class _LiquidationPageState extends State<LiquidationPage>{

  @override
  void initState(){
    super.initState();
    _main();
  }

  //ログイン状態のチェック時はこの画面が表示される
  //チェック終了後にホーム or ログインページに遷移する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: ListView(
            children: [
              SizedBox(height: 10,),
              Text("正の金額は貰う金額, 負の金額は払う金額", textAlign: TextAlign.center,),
              SizedBox(height: 10,),
              for(int i=0; i<moneyList.length; i++)...{
                Card(
                  child: ListTile(
                    // 支払った品目名と金額
                    title: Text(
                      usernameList[i] + "：" + moneyList[i].toString() + "円",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    trailing: moneyList[i] > 0 ?
                    Icon(Icons.add, color: Colors.white,) :
                    Icon(Icons.payments_outlined, color: Colors.white,),
                  ),
                  color: moneyList[i] > 0 ? Colors.lightBlue : Colors.orange,
                )
              }
            ],
          ),
        ),
      ),
    );
  }

  // usernameを追加するList
  List<String> usernameList = [];
  Future setUserNameList() async {
    for(int i=0; i<UserData.getEventUserList().length; i++){
      usernameList.add(UserData.getEventUserList()[i].username);
    }
  }
  // usernameからindexを得る関数
  int _getIndexFromUserName(String username){
    return usernameList.indexOf(username);
  }

  // 支払金額を保持するためのリスト
  List<double> moneyList = [];
  // 初期化
  Future initMoneyList() async {
    for(int i=0; i<usernameList.length; i++){
      moneyList.add(0);
    }
  }

  // firestoreから入力されたpostsを取得する
  void _getPosts() async {
    final collectionRef = FirebaseFirestore.instance.collection('posts');
    final querySnapshot = await collectionRef.get();
    final queryDocSnapshot = querySnapshot.docs;
    for (final snapshot in queryDocSnapshot) {
      final data = snapshot.data();
      // データが有効であるとき
      if(data['valid'] == true){
        // 支払ったユーザーの取得
        String _payerUserName = UserData.getUserNameFromEventUserUUID(data['payer']);

        // 支払われたユーザーUUIDリストの取得
        var _bepaidUUIDList = data['be-paid'] as List;
        // 支払われたユーザーリストの取得
        List<String> _bepaidUserNameList = [];
        for(int i=0; i<_bepaidUUIDList.length; i++){
          _bepaidUserNameList.add(UserData.getUserNameFromEventUserUUID(_bepaidUUIDList[i]));
        }

        // 支払ったユーザーが支払われたユーザーに存在するとき
        if(_isPayerExistInPaidList(_payerUserName, _bepaidUserNameList)){
          // 支払ったユーザーに関しては自分以外の人の分を貰うので、加算
          double addvalue = (data['money'] / _bepaidUserNameList.length) * (_bepaidUserNameList.length - 1);
          moneyList[_getIndexFromUserName(_payerUserName)] += addvalue;
          // 支払われたユーザーは人数で割った金額を支払うので減算
          double subvalue = data['money'] / _bepaidUserNameList.length;
          for(int i=0; i<_bepaidUserNameList.length; i++){
            String bepaidUserName = _bepaidUserNameList[i];
            if(_payerUserName != bepaidUserName){
              moneyList[_getIndexFromUserName(bepaidUserName)] -= subvalue;
            }
          }
        }
        // 支払ったユーザーが支払われたユーザーに存在しないとき
        else{
          // 支払ったユーザーは建て替えた分を貰えるので加算
          moneyList[_getIndexFromUserName(_payerUserName)] += data['money'];
          // 支払われたユーザーは人数で割った金額を支払うので減算
          double subvalue = data['money'] / _bepaidUserNameList.length;
          for(int i=0; i<_bepaidUserNameList.length; i++){
            moneyList[_getIndexFromUserName(_bepaidUserNameList[i])] -= subvalue;
          }
        }
      }
    }
  }

  // 支払ったユーザーが支払われたユーザーUUIDリストに存在するかどうかを判定する
  bool _isPayerExistInPaidList(String payerUserName, List bepaidList){
    for(int i=0; i<bepaidList.length; i++){
      if(payerUserName == bepaidList[i]){
        return true;
      }
    }
    return false;
  }

  // 清算のために用いる全ての処理をまとめた関数
  void _main() async {
    await setUserNameList();
    await initMoneyList();
    _getPosts();
  }
}
