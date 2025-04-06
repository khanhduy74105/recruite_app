import 'package:flutter/material.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/core/ui/user_avatar.dart';
import 'package:flutter_application/features/network/cubit/network_cubit.dart';
import 'package:flutter_application/models/user_connection.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyNetworkPage extends StatelessWidget {
  const MyNetworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              const InvitationsSection(),
              const Divider(thickness: 6, color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.group),
                title: Text(
                    "My Connections${state is NetworkLoaded ? " (${state.connections.length})" : ""}"),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyConnectionsPage(),
                    ),
                  );
                },
              ),
              const Divider(thickness: 6, color: Colors.grey),
              const ListTile(
                leading: Icon(Icons.people),
                title: Text("People you may know"),
              ),
              const Expanded(child: PeopleYouMayKnowSection()),
            ],
          ),
        );
      },
    );
  }
}

class MyConnectionsPage extends StatelessWidget {
  const MyConnectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Connections"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<NetworkCubit, NetworkState>(
        builder: (context, state) {
          if (state is NetworkLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NetworkError) {
            return Center(child: Text(state.error));
          } else if (state is NetworkLoaded) {
            return Column(
              children: [
                Expanded(
                    child:
                        PeopleGrid(users: state.usersFriends, areFriends: true))
              ],
            );
          }
          return const Center(child: Text("No connections available"));
        },
      ),
    );
  }
}

class InvitationsSection extends StatelessWidget {
  const InvitationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ListTile(
          leading: Icon(Icons.person_add),
          title: Text("Invitations"),
        ),
        StreamBuilder(
          stream: Supabase.instance.client
              .from('user_connection')
              .stream(primaryKey: ['id'])
              .order('created_at', ascending: false)
              .asyncMap((response) async {
                if (response.isEmpty) return <Map<String, dynamic>>[];

                final List<Map<String, dynamic>> usersRequest = [];

                for (var item in response) {
                  if (item['status'] != 'pending') continue;
                  final userId =
                      item['friend_id'] != SupabaseService.getCurrentUserId()
                          ? item['friend_id']
                          : item['user_id'];
                  final userResponse = await Supabase.instance.client
                      .from('user')
                      .select()
                      .eq('id', userId)
                      .single();

                  usersRequest.add({
                    'user': UserModel.fromJson(userResponse),
                    'connection': UserConnection.fromJson(item),
                  });
                }
                return usersRequest;
              }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else if (snapshot.hasData) {
              return InvitationsList(data: snapshot.data!);
            }
            return const Center(child: Text("No invitations available"));
          },
        ),
      ],
    );
  }
}

class InvitationsList extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const InvitationsList({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item = data[index];
        UserModel user = item['user'];
        UserConnection connection = item['connection'];
        return InvitationTile(user: user, connection: connection);
      },
    );
  }
}

class InvitationTile extends StatelessWidget {
  final UserModel user;
  final UserConnection connection;

  const InvitationTile(
      {required this.user, required this.connection, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: UserAvatar(imagePath: user.avatarUrl, size: 50),
        title: Text(user.fullName),
        subtitle: Text(user.headline ?? "Developer"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (connection.senderId != SupabaseService.getCurrentUserId())
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  context
                      .read<NetworkCubit>()
                      .acceptConnectionRequest(connection);
                },
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                context
                    .read<NetworkCubit>()
                    .rejectConnectionRequest(connection);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PeopleYouMayKnowSection extends StatelessWidget {
  const PeopleYouMayKnowSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        if (state is NetworkLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is NetworkError) {
          return Center(child: Text(state.error));
        } else if (state is NetworkLoaded) {
          return PeopleGrid(users: state.usersNotFriends, areFriends: false);
        }
        return const Center(child: Text("No users available"));
      },
    );
  }
}

class PeopleGrid extends StatelessWidget {
  final List<UserModel> users;
  final bool areFriends;

  const PeopleGrid({required this.users, super.key, required this.areFriends});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.8,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          UserModel user = users[index];
          return PeopleTile(user: user, areFriends: areFriends);
        },
      ),
    );
  }
}

class PeopleTile extends StatelessWidget {
  final UserModel user;
  final bool areFriends;

  const PeopleTile({required this.user, super.key, required this.areFriends});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UserAvatar(imagePath: user.avatarUrl, size: 100),
          const SizedBox(height: 8),
          Text(
            user.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            user.headline ?? "Developer",
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Spacer(),
          if (!areFriends)
            ElevatedButton(
              onPressed: () {
                context.read<NetworkCubit>().sendConnectionRequest(user.id);
              },
              child: const Text('Connect', style: TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }
}
