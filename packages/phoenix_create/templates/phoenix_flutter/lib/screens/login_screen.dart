import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:__PROJECT_NAME__/auth/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).login(
            email: _email.text.trim(),
            password: _password.text,
          );
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.response?.statusCode == 401
              ? 'Invalid email or password'
              : e.response == null
                  ? 'Could not connect to the server. Check your connection and try again.'
                  : 'Login failed. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not sign in. Check the server response and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FTextField(
              control: FTextFieldControl.managed(controller: _email),
              label: const Text('Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            FTextField(
              control: FTextFieldControl.managed(controller: _password),
              label: const Text('Password'),
              obscureText: true,
              error: _error == null ? null : Text(_error!),
            ),
            const SizedBox(height: 20),
            FButton(
              onPress: _loading ? null : _submit,
              child: Text(_loading ? 'Signing in...' : 'Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
