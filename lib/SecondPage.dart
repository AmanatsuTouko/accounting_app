import 'package:flutter/material.dart';
import 'firstpage.dart';

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SecondPage'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () => {Navigator.pushNamed(context, '/first')},
                child: Text('Firstページに戻る'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
