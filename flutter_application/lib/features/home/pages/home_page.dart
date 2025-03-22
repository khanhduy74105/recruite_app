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
      body: ListView(
        children: [
          // Post 1
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/profile.png"),
            ),
            title: const Text("Hưng Huỳnh"),
            subtitle: const Text("Recruiter · 15 giờ"),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "Dù đóng vai 🤡 theo kịch bản của Rap Việt mùa 1, nhưng có 1 câu của Wowy làm mình ấn tượng đến giờ:",
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: const Text("Thích"),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.comment_outlined),
                label: const Text("Bình luận"),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
                label: const Text("Đăng lại"),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send_outlined),
                label: const Text("Gửi"),
              ),
            ],
          ),
          const Divider(),

          // Advertisement
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/profile.png"),
            ),
            title: const Text("Supersonic from Unity"),
            subtitle: const Text("Được quảng bá"),
            trailing: TextButton(
              onPressed: () {},
              child: const Text("+ Theo dõi"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "Trying to navigate the AI landscape as you build out your hybrid? Supersonic's Giacomo Maragliulo...",
            ),
          ),
          const SizedBox(height: 10),
          Image.asset("assets/profile.png"),
          const Divider(),
        ],
      ),
    );
  }
}