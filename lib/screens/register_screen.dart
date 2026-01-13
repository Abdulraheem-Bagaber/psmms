import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final icController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool loading = false;
  bool obscure = true;

  String selectedRole = 'Preacher';
  final List<String> roles = ['Preacher', 'Officer', 'MUIP Admin'];

  @override
  void dispose() {
    fullNameController.dispose();
    icController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      // 1) Create Firebase Auth account
      await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 2) Save user profile in Firestore
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': fullNameController.text.trim(),
        'icNumber': icController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole, // Preacher / Officer / MUIP Admin
        'status': 'pending', // for approval flow later
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful. Pending approval.'),
        ),
      );

      // 3) Go back to Login screen
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Registration failed.';
      if (e.code == 'email-already-in-use')
        msg = 'Email is already registered.';
      if (e.code == 'weak-password')
        msg = 'Password is too weak (min 6 chars).';
      if (e.code == 'invalid-email') msg = 'Invalid email format.';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  InputDecoration _inputDeco(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF2E7D32);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Form Container
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_add,
                              size: 40,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join PSMMS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: fullNameController,
                            decoration: _inputDeco(
                              'Full Name',
                              icon: Icons.person,
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Full name is required'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: icController,
                            decoration: _inputDeco(
                              'IC Number',
                              icon: Icons.badge,
                            ),
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'IC number is required'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: phoneController,
                            decoration: _inputDeco(
                              'Phone Number',
                              icon: Icons.phone,
                            ),
                            keyboardType: TextInputType.phone,
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Phone number is required'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: emailController,
                            decoration: _inputDeco('Email', icon: Icons.email),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Email is required';
                              if (!v.contains('@'))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordController,
                            decoration: _inputDeco(
                              'Password',
                              icon: Icons.lock,
                            ).copyWith(
                              suffixIcon: IconButton(
                                onPressed:
                                    () => setState(() => obscure = !obscure),
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            obscureText: obscure,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password is required';
                              if (v.length < 6)
                                return 'Password must be at least 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Role dropdown
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: _inputDeco('Role', icon: Icons.work),
                            items:
                                roles
                                    .map(
                                      (r) => DropdownMenuItem<String>(
                                        value: r,
                                        child: Text(r),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => selectedRole = val);
                            },
                          ),

                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loading ? null : register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  loading
                                      ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed:
                                    loading
                                        ? null
                                        : () => Navigator.pop(context),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: brandGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
