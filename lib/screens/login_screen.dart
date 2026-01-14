import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool loading = false;
  bool obscure = true;

  Future<void> login() async {
    setState(() => loading = true);

    try {
      // 1️⃣ Firebase Auth login
      await authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Login failed.');

      // 2️⃣ Fetch user record
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception('Account record not found.');
      }

      final data = doc.data()!;
      final status = data['status'];

      // 🚫 Pending
      if (status == 'pending') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account is pending admin approval.\nPlease wait for approval.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // ❌ Rejected
      if (status == 'rejected') {
        await FirebaseAuth.instance.signOut();

        final reason = data['rejectionReason'];

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              reason != null && reason.toString().isNotEmpty
                  ? 'Your application was rejected.\nReason: $reason'
                  : 'Your application was rejected.\nPlease submit a new application.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // ✅ Approved
      Navigator.pushReplacementNamed(context, '/dashboard');

    } on FirebaseAuthException catch (e) {
      String msg;
      final message = e.message?.toLowerCase() ?? '';

      if (e.code == 'invalid-email') {
        msg = 'Invalid email format.';
      } else if (message.contains('password') ||
          message.contains('credential')) {
        msg = 'Incorrect password.';
      } else if (message.contains('user-not-found') ||
          message.contains('no user record')) {
        msg = 'No account found with this email.';
      } else if (message.contains('disabled')) {
        msg = 'This account has been disabled.';
      } else {
        msg = 'Login failed. Please check your credentials.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mosque, size: 64, color: Colors.teal),
                const SizedBox(height: 12),
                const Text(
                  'Preacher System Monitoring\nManagement System',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => obscure = !obscure);
                      },
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text('Create new account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}