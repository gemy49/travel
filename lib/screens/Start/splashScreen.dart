import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('IsLoggedIn');

    if (isLoggedIn != null && isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, '/BottomNavigationBar', (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/Login', (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();

    // انشاء الكنترولر للانيميشن لمدة 3.5 ثانية (3500 ملي ثانية)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // تدرج ظهور النص (fade in) من 0 الى 1
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // تحريك النص من تحت لفوق بمقدار 30% من ارتفاع الشاشة (offset)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // تشغيل الانيميشن
    _controller.forward();

    // بعد انتهاء الانيميشن والمدة، يتم فحص حالة تسجيل الدخول والتنقل للصفحة المطلوبة
    Timer(const Duration(milliseconds: 3400), () {
      if (mounted) {
        checkLoginStatus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // لازم نمسح الكنترولر بعد الاستخدام
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // خلفية الصورة كاملة
          Image.asset(
            'assets/Splash.jpeg',
            fit: BoxFit.cover,
          ),

          // نص مع انيميشن السلايد والفيد
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: Padding(
                  padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
                  child: Text(
                    "Travel Around the World",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
