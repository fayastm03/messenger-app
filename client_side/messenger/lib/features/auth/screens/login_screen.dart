import 'package:flutter/material.dart';
import 'package:messenger/features/chat/screens/home_screen.dart';
import '../widgets/custom_input.dart';
import 'package:messenger/services/api_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final ApiService _api = ApiService();

  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);

    try {
      final res = await _api.login(_email.text, _password.text);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Welcome ${res['name']}")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      print(e);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Back'), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Sign in",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A7BFF),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Please log in into your account",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            CustomInput(label: 'Email', controller: _email),

            const SizedBox(height: 15),

            CustomInput(
              label: 'Password',
              controller: _password,
              isPassword: true,
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Forgot password?",
                style: TextStyle(color: Colors.orange.shade600),
              ),
            ),

            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7BFF),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Sign in"),
                  ),

            const SizedBox(height: 20),
            _buildLoginPrompt(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Don\'t have an account? ', style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text('Click here', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
