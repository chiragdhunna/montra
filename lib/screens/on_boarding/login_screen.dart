import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/logic/blocs/login_bloc/login_bloc.dart';
import 'package:montra/screens/on_boarding/forgot_password_screen.dart';
import 'package:montra/screens/on_boarding/sign_up_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  late StreamSubscription<AuthenticationState> authStreamSubscription;
  late StreamSubscription<LoginState> loginStreamSubscription;

  Future<void> authChangeHandler(AuthenticationState state) async {
    state.maybeWhen(
      orElse: () {},
      initial: () {
        setState(() {
          isLoading = false;
        });
      },
      loggedOut: () {
        setState(() {
          isLoading = false;
        });
      },
      failure: (error) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error $error')));
        });
      },
      inProgress: () {
        setState(() {
          isLoading = true;
        });
      },
      authenticated: (user, authToken) {
        setState(() {
          isLoading = false;
        });
      },
      unAuthenticated: () {
        setState(() {
          isLoading = false;
        });
      },
      userImageUploaded: (user) {
        setState(() {
          isLoading = false;
        });
      },
      userLoggedIn: (user, authToken) {
        setState(() {
          isLoading = false;
        });
      },
      userSignedUp: () {
        setState(() {
          isLoading = false;
        });
      },
      checking: () {
        setState(() {
          isLoading = true;
        });
      },
    );
  }

  Future<void> loginChangeHandler(LoginState state) async {
    state.maybeWhen(
      orElse: () {},
      initial: () {
        setState(() {
          isLoading = false;
        });
      },
      inProgress: () {
        setState(() {
          isLoading = true;
        });
      },
      loginFail: (error) {
        setState(() {
          isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        });
      },
      loginSuccess: () {
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    authStreamSubscription = BlocProvider.of<AuthenticationBloc>(
      context,
    ).stream.listen(authChangeHandler);
    authChangeHandler(BlocProvider.of<AuthenticationBloc>(context).state);
    loginStreamSubscription = BlocProvider.of<LoginBloc>(
      context,
    ).stream.listen(loginChangeHandler);
    loginChangeHandler(BlocProvider.of<LoginBloc>(context).state);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    authStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Login",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            BlocProvider.of<LoginBloc>(context).add(
                              LoginEvent.startLogin(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill in all fields"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Don’t have an account yet? ",
                          style: const TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: "Sign Up",
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap =
                                        () => Navigator.of(
                                          context,
                                        ).pushReplacement(
                                          MaterialPageRoute(
                                            builder:
                                                (builder) => SignUpScreen(),
                                          ),
                                        ),
                              style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
