import 'package:flutter/material.dart';

class AuthenticateScreen extends StatelessWidget {
  final Future<void> Function()? onLogin;
  final Future<void> Function()? onSignup;
  const AuthenticateScreen({super.key, this.onLogin, this.onSignup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          const SizedBox(height: 10),
          const Text('Login or sign up to chat with your client.', textAlign: TextAlign.center),
          const SizedBox(height: 18),
          Wrap(spacing: 12, children: [
            ElevatedButton(onPressed: onLogin, child: const Text('Login')),
            ElevatedButton(onPressed: onSignup, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Sign up')),
          ]),
        ]),
      ),
    );
  }
}
