import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/loading_sceen.dart';
import 'main_layout.dart';

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
  bool obscure = true;

  bool hasMinLength = false;
  bool hasLower = false;
  bool hasUpper = false;
  bool hasSpecial = false;

  bool nameValid = false;
  bool phoneValid = false;
  bool emailValid = false;
  bool showContent = true;

  bool isRegisterLoading = false;

  double cardHeight = 500;

  void showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("สมัครไม่สำเร็จ"),
        content: const Text("อีเมลนี้สมัครแล้ว"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isLogin = true;
              });
            },
            child: const Text("กลับไปหน้า Login"),
          ),
        ],
      ),
    );
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    phoneController.clear();

    hasMinLength = false;
    hasLower = false;
    hasUpper = false;
    hasSpecial = false;

    nameValid = false;
    phoneValid = false;
    emailValid = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void validatePassword(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasLower = RegExp(r'[a-z]').hasMatch(password);
      hasUpper = RegExp(r'[A-Z]').hasMatch(password);
      hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  void validatePhone(String phone) {
    setState(() {
      phoneValid = phone.trim().length == 10;
    });
  }

  void validateName(String name) {
    setState(() {
      nameValid = name.trim().isNotEmpty;
    });
  }

  void validateEmail(String email) {
    setState(() {
      emailValid = email.trim().isNotEmpty;
    });
  }

  bool get isPasswordValid =>
      hasMinLength && hasLower && hasUpper && hasSpecial;

  void showTopMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget conditionRow(bool condition, String success, String error) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check_circle : Icons.cancel,
          color: condition ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            condition ? success : error,
            style: TextStyle(
              color: condition ? Colors.green : Colors.red,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> signUp() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showTopMessage("กรุณากรอกข้อมูลให้ครบ");
      return;
    }

    if (!nameValid) {
      showTopMessage("กรุณากำหนดชื่อ");
      return;
    }

    if (!phoneValid) {
      showTopMessage("กรุณาใส่เบอร์โทรศัพท์ให้ถูกต้อง");
      return;
    }

    if (!emailValid) {
      showTopMessage("กรุณาใส่ Email ให้ถูกต้อง");
      return;
    }

    if (!isPasswordValid) {
      showTopMessage("รหัสผ่านยังไม่ผ่านเงื่อนไข");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showTopMessage("รหัสผ่านไม่ตรงกัน");
      return;
    }

    setState(() => isRegisterLoading = true); // 🔥 เปิดโหลด

    try {
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
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("สมัครสมาชิกสำเร็จ กรุณาเข้าสู่ระบบ"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        isLogin = true;
        clearForm();
        cardHeight = 500;
      });
    } on AuthException catch (e) {
      showTopMessage(e.message);
    } catch (e) {
      showTopMessage("เกิดข้อผิดพลาดบางอย่าง");
    } finally {
      if (mounted) {
        setState(() => isRegisterLoading = false); // 🔥 ปิดโหลด
      }
    }
  }

  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showTopMessage("กรุณากรอก Email และ Password");
      return;
    }

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return; // 🔥 ใส่ตรงนี้

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
    } on AuthException catch (e) {
      showTopMessage("ไม่พบบัญชี กรุณาตรวจสอบอีเมลและรหัสอีกครั้ง");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 โค้ด Container ของคุณทั้งหมด
          Container(
            decoration: const BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF6EDE8),
                  Color(0xFFF4E6DF),
                  Color(0xFFFAF2EC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width < 600
                                ? 20
                                : 0,
                            vertical: MediaQuery.of(context).size.width < 600
                                ? 24
                                : 0,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                              width: double.infinity,
                              height: cardHeight,
                              child: Card(
                                color: Colors.white,
                                elevation: 8,
                                shadowColor: const Color(
                                  0xFFC56A4D,
                                ).withOpacity(0.3),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    1,
                                    24,
                                    24,
                                  ),
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 300),
                                    scale: showContent ? 1 : 0.97,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      opacity: showContent ? 1 : 0,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (isLogin)
                                            Image.asset(
                                              "assets/images/logo.png",
                                              height: 170,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return const SizedBox(); // ถ้าโหลดไม่ได้จะไม่พัง
                                                  },
                                            ),

                                          if (isLogin)
                                            const SizedBox(height: 1),

                                          Text(
                                            isLogin
                                                ? "เข้าสู่ระบบ"
                                                : "สมัครบัญชี",
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          if (!isLogin)
                                            TextField(
                                              controller: nameController,
                                              onChanged: validateName,
                                              decoration: const InputDecoration(
                                                labelText: "ชื่อ",
                                              ),
                                            ),
                                          if (!isLogin)
                                            conditionRow(
                                              nameValid,
                                              "",
                                              "กรุณากำหนดชื่อ",
                                            ),

                                          if (!isLogin)
                                            TextField(
                                              controller: phoneController,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: validatePhone,
                                              decoration: const InputDecoration(
                                                labelText: "เบอร์โทร",
                                              ),
                                            ),

                                          if (!isLogin)
                                            conditionRow(
                                              phoneValid,
                                              "",
                                              "กรุณาใส่เบอร์โทรศัพท์ให้ถูกต้อง",
                                            ),

                                          TextField(
                                            controller: emailController,
                                            onChanged: validateEmail,
                                            decoration: const InputDecoration(
                                              labelText: "Email",
                                            ),
                                          ),
                                          if (!isLogin)
                                            conditionRow(
                                              emailValid,
                                              "",
                                              "กรุณาใส่ Email",
                                            ),

                                          TextField(
                                            controller: passwordController,
                                            obscureText: obscure,
                                            onChanged: validatePassword,
                                            decoration: InputDecoration(
                                              labelText: "รหัสผ่าน",
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  obscure
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                ),
                                                onPressed: () => setState(
                                                  () => obscure = !obscure,
                                                ),
                                              ),
                                            ),
                                          ),

                                          if (!isLogin) ...[
                                            const SizedBox(height: 10),
                                            conditionRow(
                                              hasMinLength,
                                              "รหัสครบ 8 ตัวแล้ว",
                                              "ต้องมีรหัสไม่ต่ำกว่า 8 ตัว",
                                            ),
                                            conditionRow(
                                              hasLower,
                                              "มีอักษรภาษาอังกฤษพิมพ์เล็กแล้ว",
                                              "ต้องมีอักษรภาษาอังกฤษพิมพ์เล็กอย่างน้อย 1 ตัว",
                                            ),
                                            conditionRow(
                                              hasUpper,
                                              "มีอักษรภาษาอังกฤษพิมพ์ใหญ่แล้ว",
                                              "ต้องมีอักษรภาษาอังกฤษพิมพ์ใหญ่อย่างน้อย 1 ตัว",
                                            ),
                                            conditionRow(
                                              hasSpecial,
                                              "อักขระพิเศษแล้ว",
                                              "ต้องมีอักขระพิเศษอย่างน้อย 1 ตัว",
                                            ),
                                          ],

                                          if (!isLogin)
                                            TextField(
                                              controller:
                                                  confirmPasswordController,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                labelText: "ยืนยันรหัสผ่าน",
                                              ),
                                            ),

                                          const SizedBox(height: 20),

                                          ElevatedButton(
                                            onPressed: isLogin
                                                ? signIn
                                                : signUp,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFF28C6F,
                                              ), // 👈 ใส่ตรงนี้
                                              foregroundColor:
                                                  Colors.white, // 👈 ใส่ตรงนี้
                                              minimumSize: const Size(
                                                double.infinity,
                                                50,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              isLogin ? "Login" : "Register",
                                            ),
                                          ),

                                          TextButton(
                                            onPressed: () async {
                                              // 1️⃣ fade ออก
                                              setState(
                                                () => showContent = false,
                                              );

                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 200,
                                                ),
                                              );

                                              // 2️⃣ ขยายก่อน
                                              setState(() {
                                                cardHeight = isLogin
                                                    ? 700
                                                    : 500;
                                              });

                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 400,
                                                ),
                                              );

                                              // 3️⃣ ค่อยเปลี่ยนหน้า
                                              setState(() {
                                                isLogin = !isLogin;
                                                clearForm();
                                              });

                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 50,
                                                ),
                                              );

                                              // 4️⃣ fade เข้า
                                              setState(
                                                () => showContent = true,
                                              );
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
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (isRegisterLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "กำลังสร้างบัญชี...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

PageRouteBuilder fadeRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
