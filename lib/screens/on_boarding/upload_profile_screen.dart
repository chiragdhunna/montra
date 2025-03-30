import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  late StreamSubscription<AuthenticationState> authStreamSubscription;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
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

  @override
  void initState() {
    // TODO: implement initState
    authStreamSubscription = BlocProvider.of<AuthenticationBloc>(
      context,
    ).stream.listen(authChangeHandler);
    authChangeHandler(BlocProvider.of<AuthenticationBloc>(context).state);
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
      appBar: AppBar(
        title: const Text("Profile Photo"),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child:
                          _image == null
                              ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey[600],
                              )
                              : null,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "A photo of you",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please make sure your photo clearly shows your face.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Take Photo",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        "Choose from Gallery",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed:
              _image != null
                  ? () {
                    BlocProvider.of<AuthenticationBloc>(
                      context,
                    ).add(AuthenticationEvent.uploadProfileImage(_image!));
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("Upload Image", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
