import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import '../login_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String email;
  final String password;

  const LoadingScreen({super.key, required this.email, required this.password});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _login();
  }

  Future<void> _login() async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: widget.email,
        password: widget.password,
      );

      if (response.user != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, animation, __) =>
                FadeTransition(opacity: animation, child: const HomeScreen()),
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) =>
              FadeTransition(opacity: animation, child: const LoginScreen()),
        ),
      );

      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      });
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) =>
              FadeTransition(opacity: animation, child: const LoginScreen()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", height: 150),
            const SizedBox(height: 40),
            const Text(
              "กำลังเข้าสู่ระบบ...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            const CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
