import 'dart:async';

import 'package:flutter/material.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/logic/blocs/login_bloc/login_bloc.dart';
import 'package:montra/screens/on_boarding/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isChecked = false;
  bool _obscurePassword = true;
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late StreamSubscription<AuthenticationState> authStreamSubscription;
  late StreamSubscription<LoginState> loginStreamSubscription;

  bool get _allFieldsFilled =>
      nameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty;

  void _updateState() {
    // This forces a rebuild when text changes
    setState(() {});
  }

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
          if (error == 'Error getting profile image') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$error , please upload it again!!'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: Colors.red),
            );
          }
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
    nameController.addListener(_updateState);
    emailController.addListener(_updateState);
    passwordController.addListener(_updateState);

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
    // Clean up controllers and listeners
    nameController.removeListener(_updateState);
    emailController.removeListener(_updateState);
    passwordController.removeListener(_updateState);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
          "Sign Up",
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
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Name",
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
                        controller: emailController,
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
                        controller: passwordController,
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
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value ?? false;
                              });
                            },
                            activeColor: Colors.purple,
                          ),
                          const Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: "By signing up, you agree to the ",
                                style: TextStyle(color: Colors.black54),
                                children: [
                                  TextSpan(
                                    text: "Terms of Service",
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: " and "),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty &&
                                emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              BlocProvider.of<LoginBloc>(context).add(
                                LoginEvent.signUp(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  name: nameController.text,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Please fill all the fields"),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (_allFieldsFilled && _isChecked)
                                    ? Colors.purple
                                    : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Center(
                        child: Text(
                          "Or with",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Comming Soon")),
                            );
                          },
                          icon: Image.asset(
                            "assets/googleLogo.png",
                            height: 20,
                          ),
                          label: const Text(
                            "Sign Up with Google",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (builder) => LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
