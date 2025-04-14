import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_application/features/home/pages/home_page.dart';
import 'package:flutter_application/features/message/pages/page.dart';
import 'package:flutter_application/features/network/pages/network_page.dart';
import 'package:flutter_application/features/post/pages/post_page.dart';
import 'package:flutter_application/features/profile/pages/profile.dart';
import 'package:flutter_application/features/notifications/pages/notifications_page.dart';
import 'package:flutter_application/features/jobs/pages/jobs_page.dart';
import 'package:flutter_application/features/setting/page/account_setting_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/setting/cubit/setting_cubit.dart';

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
    const MyNetworkPage(),
    const SizedBox(),
    const NotificationsPage(),
    const JobsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load user settings when the widget is initialized
    context.read<SettingsCubit>().loadSettings();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      showCreatePostScreen(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const UserAccountsDrawerHeader(
                  accountName: Text('Loading...'),
                  accountEmail: Text('Loading...'),
                  currentAccountPicture: CircleAvatar(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (state.error != null) {
                return UserAccountsDrawerHeader(
                  accountName: const Text('Error'),
                  accountEmail: Text(state.error!),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                );
              }

              return UserAccountsDrawerHeader(
                accountName: Text(state.user.fullName),
                accountEmail: Text(state.user.email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: state.user.avatarUrl != null
                      ? NetworkImage(state.user.avatarUrl!)
                      : const AssetImage("assets/profile.png") as ImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    // Fallback to default image if the network image fails to load
                    setState(() {});
                  },
                  child: state.user.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("View Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage(userId: SupabaseService.getCurrentUserId(),)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              context.read<AuthCubit>().logout();
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagePage(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.message_rounded,
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
