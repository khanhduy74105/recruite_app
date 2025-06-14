import 'package:flutter/material.dart';
import 'package:flutter_application/features/home/cubit/home_cubit.dart';
import 'package:flutter_application/features/home/widgets/post_card_widget.dart';
import 'package:flutter_application/features/network/repository/network_repository.dart';
import 'package:flutter_application/models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SingleChildScrollView(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoadingPost) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeError) {
              return Center(child: Text(state.error));
            }
            if (state is HomeLoadedPost) {
              return ListView.builder(
                padding: const EdgeInsets.all(0),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  PostModel postModel = state.posts[index];
                  return PostCardWidget(postModel: postModel);
                },
              );
            }
            return const Center(child: Text("No posts available"));
          },
        ),
      )
    );
  }
}