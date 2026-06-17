import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = TokenStorage();
  final token = await storage.getToken();

  runApp(
    ProviderScope(
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const HomePlaceholder() : LoginScreen(),
    );
  }
}

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EduQuest')),
      body: const Center(
        child: Text('Welcome back! You are logged in.'),
      ),
    );
  }
}