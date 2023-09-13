import 'package:flutter/material.dart';

class ChooseCreateAccountOrLogin extends StatefulWidget {
  @override
  _ChooseCreateAccountOrLoginState createState() => _ChooseCreateAccountOrLoginState();
}

class _ChooseCreateAccountOrLoginState extends State<ChooseCreateAccountOrLogin> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              // ユーザー登録
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('新規ユーザー登録'),
                  onPressed: () {
                    Navigator.pushNamed(context,"/create-account");
                  },
                ),
              ),

              // ログインボタン
              Container(
                width: double.infinity,
                child: OutlinedButton(
                  child: Text('ログイン'),
                  onPressed: () {
                    Navigator.pushNamed(context,"/login");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
