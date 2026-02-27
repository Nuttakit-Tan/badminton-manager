import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLogin = true;

  String? validatePassword(String password) {
    if (password.length < 8) {
      return "รหัสต้องอย่างน้อย 8 ตัว";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "ต้องมีตัวพิมพ์ใหญ่";
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "ต้องมีตัวพิมพ์เล็ก";
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "ต้องมีตัวเลข";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return "ต้องมีอักขระพิเศษ";
    }
    return null;
  }

  Future<void> signUp() async {
    final passwordError = validatePassword(passwordController.text);
    if (passwordError != null) {
      showMessage(passwordError);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage("รหัสผ่านไม่ตรงกัน");
      return;
    }

    final response = await supabase.auth.signUp(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final user = response.user;
    if (user != null) {
      await supabase.from('profiles').insert({
        'id': user.id,
        'email': emailController.text.trim(),
        'full_name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      showMessage("สมัครสมาชิกสำเร็จ");
    }
  }

  Future<void> signIn() async {
    await supabase.auth.signInWithPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    showMessage("เข้าสู่ระบบสำเร็จ");
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (!isLogin)
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "ชื่อ"),
              ),
            if (!isLogin)
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "เบอร์โทร"),
              ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            if (!isLogin)
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLogin ? signIn : signUp,
              child: Text(isLogin ? "Login" : "Register"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? "ยังไม่มีบัญชี? สมัครสมาชิก"
                    : "มีบัญชีแล้ว? เข้าสู่ระบบ",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
