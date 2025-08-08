import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  final String? email;

  const ResetPasswordScreen({super.key, this.token, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController _emailController;
  late TextEditingController _tokenController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
    _tokenController = TextEditingController(text: widget.token ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        token.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _loading = true);

    final url = Uri.parse('http://192.168.100.10:3000/api/reset-password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_emailController, "Email"),
                    const SizedBox(height: 15),
                    _buildTextField(_tokenController, "Verification Code"),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _newPasswordController,
                      "New Password",
                      obscure: true,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      _confirmPasswordController,
                      "Confirm Password",
                      obscure: true,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF3DB9EF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Reset Password"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF3DB9EF)),
      decoration: InputDecoration(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3DB9EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3DB9EF), width: 2),
        ),
      ),
    );
  }
}
