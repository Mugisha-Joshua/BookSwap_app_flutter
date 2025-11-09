import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';
import 'my_offers_screen.dart';
import 'received_offers_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  final bool showBackButton;

  const SettingsScreen({super.key, this.showBackButton = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationReminders = true;
  bool _emailUpdates = true;

  Future<void> _signOut() async {
    try {
      final authService = AuthService();
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.darkBlue,
                    child: Text(
                      FirebaseAuth.instance.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 24, color: AppTheme.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? '',
                          style: const TextStyle(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notification reminders',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Switch(
                        value: _notificationReminders,
                        onChanged: (value) {
                          setState(() {
                            _notificationReminders = value;
                          });
                        },
                        activeTrackColor: AppTheme.yellowAccent,
                        activeThumbColor: AppTheme.yellowAccent,
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Email Updates',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Switch(
                        value: _emailUpdates,
                        onChanged: (value) {
                          setState(() {
                            _emailUpdates = value;
                          });
                        },
                        activeTrackColor: AppTheme.yellowAccent,
                        activeThumbColor: AppTheme.yellowAccent,
                      ),
                    ],
                  ),
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
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppTheme.darkBlue),
                  title: const Text(
                    'My Offers',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MyOffersScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.inbox, color: AppTheme.darkBlue),
                  title: const Text(
                    'Received Offers',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReceivedOffersScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.darkBlue),
                  title: const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About BookSwap'),
                        content: const Text(
                          'BookSwap is a marketplace where students can swap textbooks with each other.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

