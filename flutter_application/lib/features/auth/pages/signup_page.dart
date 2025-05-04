import 'package:flutter/material.dart';
import 'package:flutter_application/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_application/features/auth/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  static MaterialPageRoute route() => MaterialPageRoute(
        builder: (context) => const SignupPage(),
      );

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signUpUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocConsumer<AuthCubit, AuthStates>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is AuthSignUp) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Account created! Login NOW!")),
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        margin: const EdgeInsets.all(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Sign Up.",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: const Icon(Icons.email),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        !value.trim().contains("@")) {
                                      return "Please enter a valid email";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: !_passwordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(_passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty ||
                                        value.trim().length < 8) {
                                      return "Password must be at least 8 characters";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) {
                                    if (value != passwordController.text) {
                                      return "Passwords do not match";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: signUpUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                  ),
                                  child: state is AuthLoading
                                      ? Container(
                                          width: 20,
                                          height: 20,
                                          alignment: Alignment.center,
                                          child:
                                              const CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'SIGN UP',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const LoginPage(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return FadeTransition(
                                              opacity: animation, child: child);
                                        },
                                      ),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: 'Sign In',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
