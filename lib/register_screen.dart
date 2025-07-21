import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const RegisterScreen({super.key, required this.toggleTheme});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _message = '';

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final emailOrPhone = _emailOrPhoneController.text.trim();

    if (username.isEmpty || password.isEmpty || emailOrPhone.isEmpty) {
      setState(() {
        _message = "All fields are required.";
      });
      return;
    }

    final url = Uri.parse('http://192.168.20.207:8000/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
          'contact': emailOrPhone,
        },
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (data['status'] == 'success') {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("✅ Registration Successful"),
            content: const Text("You can now login with your credentials."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(toggleTheme: widget.toggleTheme),
                    ),
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _message = data['message'] ?? 'Registration failed';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '❌ Connection failed. Make sure server is running.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                onFieldSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailOrPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Email or Mobile Number',
                ),
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onFieldSubmitted: (_) => _handleRegister(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleRegister,
                child: const Text('Register'),
              ),
              const SizedBox(height: 10),
              Text(
                _message,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
