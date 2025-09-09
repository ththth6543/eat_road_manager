import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eat_road_manager/main.dart';

final supabase = Supabase.instance.client;

class MainLoginScreen extends StatefulWidget {
  const MainLoginScreen({super.key});

  @override
  State<MainLoginScreen> createState() => _MainLoginScreenState();
}

class _MainLoginScreenState extends State<MainLoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패 : ${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            (route) => false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사장님 로그인')),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(16),
          child: _isLoading
            ? const CircularProgressIndicator()
              : ElevatedButton.icon(onPressed: _signInWithGoogle,
              label: const Text('Google로 로그인'),
            icon: const Icon(Icons.login),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      )
    );
  }
}
