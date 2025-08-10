import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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

  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool pass = true;
  bool confirmPass = true;

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

  void _showSnackBar(Color bgColor, IconData icon, String message) {
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      // لو في خطأ في التحقق، مابنعملش حاجة
      return;
    }

    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      _showSnackBar(
        Colors.orange,
        Icons.warning_amber_rounded,
        'Passwords do not match',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService().resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      final statusCode = result['statusCode'];
      final data = result['data'];

      if (statusCode == 200) {
        _showSnackBar(
          Colors.green,
          Icons.check_circle_outline,
          'Password reset successful',
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showSnackBar(Colors.red, Icons.error_outline, 'Failed: $data');
      }
    } catch (e) {
      _showSnackBar(Colors.red, Icons.error_outline, 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
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
                  _buildTextFormField(
                    _emailController,
                    "Email",
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextFormField(
                    _tokenController,
                    "Verification Code",
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Verification code is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextFormField(
                    _newPasswordController,
                    "New Password",
                    obscure: pass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        pass ? Icons.visibility : Icons.visibility_off,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => pass = !pass),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'New password is required';
                      }
                      if (val.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildTextFormField(
                    _confirmPasswordController,
                    "Confirm Password",
                    obscure: confirmPass,
                    suffixIcon: IconButton(
                      icon: Icon(
                        confirmPass ? Icons.visibility : Icons.visibility_off,
                        color: Colors.amber,
                      ),
                      onPressed: () =>
                          setState(() => confirmPass = !confirmPass),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
