import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AddPostPage.dart';
import 'ChatPage.dart';
import 'LoginPage.dart';
import 'FirstPage.dart';
import 'SecondPage.dart';
import 'MainScreen.dart';
import 'UserData.dart';

// FireBase
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // FireBaseの初期化処理
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginCheck(),
      // ルーティングの定義
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(),
        '/main' : (context) => MainScreen(),
        '/chat': (context) => ChatPage(),
        '/post': (context) => AddPostPage(),
        '/first': (context) => FirstPage(),
        '/second': (context) => SecondPage(),
      },
    );
  }
}

// ログイン状態のチェックと遷移を行う
class LoginCheck extends StatefulWidget{
  LoginCheck({Key, key}) : super(key: key);

  @override
  _LoginCheckState createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck>{
  //ログイン状態のチェック(非同期で行う)
  void checkUser() async{
    final currentUser = await FirebaseAuth.instance.currentUser;
    if(currentUser == null){
      // 未ログインの時
      await Navigator.pushReplacementNamed(context,"/login");
    }else{
      // ログイン済みの時
      // Userデータをstaticに取得できるように保存しておく
      await UserData.setUserData(user: currentUser);
      await Navigator.pushReplacementNamed(context, "/main");
    }
  }

  @override
  void initState(){
    super.initState();
    checkUser();
  }
  //ログイン状態のチェック時はこの画面が表示される
  //チェック終了後にホーム or ログインページに遷移する
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text("Loading..."),
        ),
      ),
    );
  }
}