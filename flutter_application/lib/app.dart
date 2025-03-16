import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/features/home/pages/home_page.dart';
import 'package:flutter_application/features/profile/pages/profile.dart';

class AppBottomNavigatorBar extends StatefulWidget {
  const AppBottomNavigatorBar({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const AppBottomNavigatorBar(),
      );

  @override
  _AppBottomNavigatorBarState createState() => _AppBottomNavigatorBarState();
}

class _AppBottomNavigatorBarState extends State<AppBottomNavigatorBar> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const HomePage(),
    const Center(child: Text("My Network", style: TextStyle(fontSize: 24))),
    const SizedBox(),
    const Center(child: Text("Notifications", style: TextStyle(fontSize: 24))),
    const Center(child: Text("Jobs", style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showPostModal();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showPostModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Create a Post",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
           UserAccountsDrawerHeader(
            accountName: Text("Nguyen Van A"),
            accountEmail: Text("nguyenvana@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: Image.asset("assets/profile.png").image,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("View Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
          SliverAppBar(
            pinned: false,
            snap: true,
            floating: true,
            expandedHeight: 60,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            actions: [
              GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: CircleAvatar(
                  backgroundImage: Image.asset("assets/profile.png").image,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ];
        },
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Network',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box, size: 32, color: Colors.blue),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Noti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
        ],
      ),
    );
  }
}
