import 'dart:async';
import 'package:flutter/material.dart';
import '../main_layout.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _goToHome();
  }

  Future<void> _goToHome() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return; // 🔥 สำคัญมาก

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const MainLayout()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6EDE8), Color(0xFFFAF2EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.8, end: 1),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Image.asset("assets/images/logo.png", height: 140),
              ),
              const SizedBox(height: 30),
              const Text(
                "กำลังเตรียมระบบ...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B3E2E),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFFF28C6F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
