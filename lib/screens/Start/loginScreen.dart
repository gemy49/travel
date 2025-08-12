import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool pass = true;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _showSnackBarMessage(String message, Color bgColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final result = await ApiService().loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result['success']) {
        final userData = result['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('IsLoggedIn', true);
        await prefs.setString("token", userData['token']);
        await prefs.setInt("userId", userData['user']['id']);
        await prefs.setString("email", userData['user']['email']);
        await prefs.setString("name", userData['user']['name']);
        await prefs.setString("phone", userData['user']['phone']);

        _showSnackBarMessage(
          "Welcome ${userData['user']['name']}",
          Colors.green,
          Icons.check_circle_outline,
        );

        Navigator.pushNamedAndRemoveUntil(context, '/BottomNavigationBar', (route) => false);
      } else {
        _showSnackBarMessage(
          "Incorrect email or password",
          Colors.red,
          Icons.error_outline,
        );
      }
    } catch (e) {
      _showSnackBarMessage(
        'An error occurred. Please try again.',
        Colors.red,
        Icons.error_outline,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: constraints.maxHeight * 0.02,
                    right: constraints.maxHeight * 0.02,
                    top: constraints.maxHeight * 0.2,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Fly High',
                          style: TextStyle(
                            fontSize: constraints.maxHeight * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.05),

                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          style: const TextStyle(color: Color(0xFF3DB9EF)),
                          decoration: InputDecoration(
                            label: const Text(
                              'Email',
                              style: TextStyle(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF3DB9EF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF3DB9EF),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: constraints.maxHeight * 0.03),
                        TextFormField(
                          controller: passwordController,
                          obscureText: pass,
                          style: const TextStyle(color: Color(0xFF3DB9EF)),
                          decoration: InputDecoration(
                            label: const Text(
                              'Password',
                              style: TextStyle(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF3DB9EF),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF3DB9EF),
                                width: 2,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  pass = !pass;
                                });
                              },
                              icon: Icon(
                                pass ? Icons.visibility : Icons.visibility_off,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.amber),
                            ),
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.02),
                        SizedBox(
                          width: constraints.maxHeight * 0.3,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF3DB9EF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: constraints.maxHeight * 0.025,
                                    ),
                                  ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/signup'),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(color: Color(0xFF3DB9EF)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
