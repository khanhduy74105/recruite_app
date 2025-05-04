import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_application/features/auth/pages/login_page.dart';
import 'package:flutter_application/features/home/pages/home_page.dart';
import 'package:flutter_application/features/jobs/pages/jobs_page.dart';
import 'package:flutter_application/features/message/pages/page.dart';
import 'package:flutter_application/features/network/pages/network_page.dart';
import 'package:flutter_application/features/notifications/pages/notifications_page.dart';
import 'package:flutter_application/features/post/pages/post_page.dart';
import 'package:flutter_application/features/profile/pages/profile.dart';
import 'package:flutter_application/features/setting/cubit/setting_cubit.dart';
import 'package:flutter_application/features/setting/page/account_setting_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 150,
                  child: const Center(
                    child: CircleAvatar(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              if (state.error != null) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 150,
                  child: const Center(
                    child: CircleAvatar(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                );
              }

              return Container(
                width: double.infinity,
                child: Stack(
                  children: [
                    // Background with ShaderMask
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.black.withOpacity(0.3),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.darken,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/drawer_background.png"),
                              // Your image path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Foreground content (avatar, name, email)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: state.user.avatarUrl != null
                                ? NetworkImage(state.user.avatarUrl!)
                                : const AssetImage("assets/profile.png")
                                    as ImageProvider,
                            onBackgroundImageError: (exception, stackTrace) {
                              setState(() {});
                            },
                            child: state.user.avatarUrl == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user.fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                state.user.email,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                MaterialPageRoute(
                  builder: (_) =>
                      ProfilePage(userId: SupabaseService.getCurrentUserId()),
                ),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
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
