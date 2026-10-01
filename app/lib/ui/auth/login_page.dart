import 'package:flutter/material.dart';

import 'package:app/data/repositories/auth_repository.dart';
import 'package:app/data/repositories/events_repository.dart';
import 'package:app/ui/calendar/home_page.dart';
import 'package:app/ui/core/spacing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.authRepository,
    required this.eventsRepository,
  });

  final AuthRepository authRepository;
  final EventsRepository eventsRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    try {
      await widget.authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              HomePage(eventsRepository: widget.eventsRepository),
        ),
      );
    } on AuthFailure catch (error) {
      debugPrint('Login failed: ${error.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: pagePadding,
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _logIn, child: const Text("Log in")),
          ],
        ),
      ),
    );
  }
}
