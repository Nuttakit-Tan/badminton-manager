import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jvtwwhtimvyrmvpkywyd.supabase.co',
    anonKey: 'sb_publishable_mH7fnVXeyl6u-nN9i_e6VA_itdABV4Q',
  );

  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: const Locale('th', 'TH'), // 👈 เพิ่มบรรทัดนี้

      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6EDE8),

        primaryColor: const Color(0xFFF28C6F),

        colorScheme: const ColorScheme.light(
          primary: Color(0xFFF28C6F),
          secondary: Color(0xFFC56A4D),
          background: Color(0xFFF6EDE8),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF28C6F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF28C6F)),
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
