import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerWidget {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            if (authState.token != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Registration successful! Token saved.',
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            ElevatedButton(
              onPressed: authState.loading
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).register({
                        'name': nameController.text,
                        'email': emailController.text,
                        'password': passwordController.text,
                      });
                    },
              child: authState.loading
                  ? const CircularProgressIndicator()
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}