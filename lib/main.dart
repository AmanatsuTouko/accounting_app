import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AddPostPage.dart';
import 'ChatPage.dart';
import 'LoginPage.dart';
import 'FirstPage.dart';
import 'SecondPage.dart';
import 'UserData.dart';

// FireBase
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

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
      // ルーティングの定義
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/first': (context) => FirstPage(),
        '/second': (context) => SecondPage(),
        '/login': (context) => LoginPage(),
        '/chat': (context) => ChatPage(),
        '/post': (context) => AddPostPage(),
      },
    );
  }
}
