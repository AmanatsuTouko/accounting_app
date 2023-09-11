import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AddPostPage.dart';
import 'ChatPage.dart';
import 'UserData.dart';

class MainScreen extends StatefulWidget{
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  var _currentPageIndex = 0;
  final _pageViewController = PageController();

  final User user = UserData.getUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCurrentTitle(_currentPageIndex),
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),),
        backgroundColor: Colors.purple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // ハンバーガーメニューの表示
      drawer: Drawer(
        child: Stack(
          children: <Widget>[
            ListView(
              children: [
                SizedBox(
                  height: 80,
                  child: const DrawerHeader(decoration: BoxDecoration(color: Colors.purple,),
                    child: Text('イベント一覧',
                      style: TextStyle(color: Colors.white, fontSize: 24,),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.trip_origin),
                  title: Text('宮崎旅行 2023/9 (仮)'),
                  onTap: (){},
                ),
                ListTile(
                  leading: Icon(Icons.trip_origin),
                  title: Text('佐賀旅行 2023/7 (仮)'),
                  onTap: (){},
                ),
              ],
            ),
            Positioned(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text("ログアウト"),
                        onTap: _logout,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Text('イベント情報：〇〇旅行(仮)'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Text('ログイン情報：${user.email}'),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
      body: Center(
          child : PageView(
            controller: _pageViewController,
            onPageChanged: (int index) => _onPageChanged(index),
            children: [
              AddPostPage(),
              ChatPage(),
              const Center(
                child: Text('清算した金額を表示'),
              ),
              const Center(
                child: Text('設定を表示'),
              ),
            ],
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => _onTapBottomNavigationItem(index),
        currentIndex: _currentPageIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: '入力'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: '履歴'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money_outlined),
              activeIcon: Icon(Icons.attach_money),
              label: '清算'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '設定'
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int index){
    setState(() {
      _currentPageIndex = index;
    });
  }
  void _onTapBottomNavigationItem(int index){
    _pageViewController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }
  String _getCurrentTitle(int index){
    if(index == 0) return "入力";
    if(index == 1) return "履歴";
    if(index == 2) return "清算";
    if(index == 3) return "設定";
    else return "ERROR";
  }

  void _logout() async {
    // ログアウト処理 内部で保持しているログイン情報等が初期化される
    await FirebaseAuth.instance.signOut();
    // ログイン画面に遷移
    await Navigator.pushReplacementNamed(context, '/');
  }
}