import 'package:flutter/material.dart';

class MyNetworkPage extends StatelessWidget {
  const MyNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Network")),
      body: const Center(
        child: Text("My Network Page", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}