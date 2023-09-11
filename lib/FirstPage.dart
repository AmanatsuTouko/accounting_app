import 'package:flutter/material.dart';
import 'SecondPage.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FirstPage'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () => {Navigator.pushNamed(context, '/second')},
                child: Text('Nextページへ'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
