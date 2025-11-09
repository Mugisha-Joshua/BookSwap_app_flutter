import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    // Check every 3 seconds if email is verified
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerificationSilently();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerificationSilently() async {
    try {
      await _authService.reloadUser();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified == true && mounted) {
        _timer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _checkEmailVerification() async {
    setState(() => _isLoading = true);
    try {
      await _authService.reloadUser();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified == true && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your email and try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isLoading = true);
    try {
      await _authService.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 80, color: AppTheme.white),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We sent a verification email to:\n${FirebaseAuth.instance.currentUser?.email ?? ''}\n\nPlease check your email (including spam folder) and click the verification link.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppTheme.white),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _checkEmailVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.yellowAccent,
                  foregroundColor: AppTheme.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('I\'ve Verified My Email'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading ? null : _resendVerification,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.white,
                  side: const BorderSide(color: AppTheme.white),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}