import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/app.dart';
import 'package:flutter_application/core/constants/env.dart';
import 'package:flutter_application/core/constants/theme.dart';
import 'package:flutter_application/core/services/supabase_service.dart';
import 'package:flutter_application/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_application/features/auth/pages/signup_page.dart';
import 'package:flutter_application/features/home/cubit/home_cubit.dart';
import 'package:flutter_application/features/home/pages/home_page.dart';
import 'package:flutter_application/features/network/cubit/network_cubit.dart';
import 'package:flutter_application/features/post/cubit/post_cubit.dart';
import 'package:flutter_application/features/setting/cubit/setting_cubit.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await SupabaseService.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()..checkCurrentUser()),
        BlocProvider(create: (_) => PostCubit()),
        BlocProvider(create: (_) => NetworkCubit()..getUsers()),
        BlocProvider(create: (_) => HomeCubit()..getPosts()),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: linkedInTheme,
      home: BlocBuilder<AuthCubit, AuthStates>(
        builder: (context, state) {
          if (state is AuthLoggedIn) {
            return const AppBottomNavigatorBar();
          }
          return const SignupPage();
        },
      ),
    );
  }
}