import 'package:app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:app/ui/core/themes/dimens.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.login.removeListener(_onResult);
    widget.viewModel.login.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.login.removeListener(_onResult);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.login.error) {
      widget.viewModel.login.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: Dimens.edgeInsetsScreen,
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
            ListenableBuilder(
              listenable: widget.viewModel.login,
              builder: (context, _) {
                return FilledButton(
                  onPressed: widget.viewModel.login.running
                      ? null
                      : () => widget.viewModel.login.execute((
                          _emailController.text,
                          _passwordController.text,
                        )),
                  child: const Text('Log in'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
