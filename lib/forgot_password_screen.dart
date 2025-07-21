import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController contactController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool otpSent = false;
  bool otpVerified = false;

  Future<void> sendForgotPassword(String contact) async {
    final url = Uri.parse('http://192.168.20.207:8000/forgot_password');
    final response = await http.post(
      url,
      body: {'contact': contact},
    );

    if (response.statusCode == 200) {
      logger.i('✅ OTP sent successfully');
      if (!mounted) return;
      setState(() {
        otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP sent to your mobile")),
      );
    } else {
      logger.e('❌ Failed to send OTP: ${response.body}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  }

  Future<void> verifyOtp(String contact, String otp) async {
    final url = Uri.parse('http://192.168.20.207:8000/verify_otp');
    final response = await http.post(
      url,
      body: {
        'contact': contact,
        'otp': otp,
      },
    );

    if (response.statusCode == 200) {
      logger.i('✅ OTP verified');
      if (!mounted) return;
      setState(() {
        otpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Verified")),
      );
    } else {
      logger.e('❌ Invalid OTP: ${response.body}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP")),
      );
    }
  }

  Future<void> resetPassword(String contact, String newPassword) async {
    final url = Uri.parse('http://192.168.20.207:8000/reset_password');
    final response = await http.post(
      url,
      body: {
        'contact': contact,
        'new_password': newPassword,
      },
    );

    if (response.statusCode == 200) {
      logger.i('✅ Password reset successful');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Reset Successful")),
      );
    } else {
      logger.e('❌ Failed to reset password: ${response.body}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Reset Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                sendForgotPassword(contactController.text);
              },
              child: const Text('Send OTP'),
            ),
            if (otpSent) ...[
              const SizedBox(height: 24),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  verifyOtp(contactController.text, otpController.text);
                },
                child: const Text('Verify OTP'),
              ),
            ],
            if (otpVerified) ...[
              const SizedBox(height: 24),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  resetPassword(
                    contactController.text,
                    newPasswordController.text,
                  );
                },
                child: const Text('Reset Password'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
