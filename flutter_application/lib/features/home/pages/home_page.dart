import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
        children: [
            Container(
            height: 300,
            color: Colors.red,
            ),
            Container(
            height: 300,
            color: Colors.green,
            ),
            Container(
            height: 300,
            color: Colors.blue,
            ),
            Container(
            height: 300,
            color: Colors.yellow,
            ),
            Container(
            height: 300,
            color: Colors.orange,
            ),
        ],
      ),
      ),
    );
  }
}