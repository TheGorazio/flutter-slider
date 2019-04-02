import 'package:flutter/material.dart';
import 'slider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _age = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'How old are you?',
                  style: TextStyle(
                    fontSize: 36,
                  ),
                ),
                MySlider(
                  width: 300,
                  height: 50,
                  color: Colors.black,
                  onChanged: (double value) =>
                      setState(() => _age = (value * 100).round()),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    mainAxisAlignment: MainAxisAlignment.end,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        _age.toString(),
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Text(
                          'years',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
