import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('Please sign in to view your profile'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final displayName = userData?['displayName'] as String? ?? user.displayName ?? 'User';
          final email = user.email ?? '';
          final emailVerified = user.emailVerified;
          final photoURL = userData?['photoURL'] as String? ?? user.photoURL;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.darkBlue.withValues(alpha: 0.1),
                        backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                        child: photoURL == null
                            ? Text(
                                displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkBlue,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            emailVerified ? Icons.verified : Icons.warning,
                            color: emailVerified ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            emailVerified ? 'Email Verified' : 'Email Not Verified',
                            style: TextStyle(
                              fontSize: 14,
                              color: emailVerified ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (!emailVerified) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await _authService.sendEmailVerification();
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Verification email sent! Please check your inbox.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('Send Verification Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.yellowAccent,
                            foregroundColor: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.darkBlue),
                  title: const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'User ID: ${user.uid.substring(0, 8)}...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

