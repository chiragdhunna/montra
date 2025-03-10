import 'package:flutter/material.dart';
import 'package:montra/screens/on_boarding/reset_password_screen.dart';

class ForgotPasswordEmailSentScreen extends StatefulWidget {
  const ForgotPasswordEmailSentScreen({super.key});

  @override
  State<ForgotPasswordEmailSentScreen> createState() =>
      _ForgotPasswordEmailSentScreenState();
}

class _ForgotPasswordEmailSentScreenState
    extends State<ForgotPasswordEmailSentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/email_sent.png", // Replace with your actual image asset path
              height: 200,
            ),
            const SizedBox(height: 30),
            const Text(
              "Your email is on the way",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Check your email test@test.com and follow the instructions to reset your password",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to login screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (builder) => ResetPasswordScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Back to Login",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
