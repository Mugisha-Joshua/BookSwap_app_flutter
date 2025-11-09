import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/swap_offer.dart';
import '../services/swap_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class MyOffersScreen extends StatelessWidget {
  final bool showBackButton;

  const MyOffersScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final swapService = SwapService();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Offers'),
        ),
        body: const Center(
          child: Text('Please sign in to view your offers'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('My Offers'),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: StreamBuilder<List<SwapOffer>>(
        stream: swapService.getMyOffers(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final offers = snapshot.data ?? [];

          if (offers.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t made any swap offers yet.\nBrowse listings and tap "Swap" to make an offer!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textLight,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.darkBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: offer.bookImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  offer.bookImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.book,
                                      size: 30,
                                      color: AppTheme.darkBlue,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.book,
                                size: 30,
                                color: AppTheme.darkBlue,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.bookTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'To: ${offer.recipientName}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(offer.status)
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    offer.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(offer.status),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.chat),
                                  color: AppTheme.darkBlue,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          otherUserId: offer.recipientId,
                                          otherUserName: offer.recipientName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return AppTheme.darkBlue;
      default:
        return AppTheme.textLight;
    }
  }
}

