import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:my_starter_app/auth/auth_provider.dart';
import 'package:my_starter_app/auth/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).value;
    final json = auth is Authenticated ? auth.user : null;
    final user = json == null ? null : jsonDecode(json) as Map<String, dynamic>;

    return FScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user?['email'] ?? ''),
            const SizedBox(height: 20),
            FButton(
              onPress: () => ref.read(authServiceProvider).logout(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
