import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/book_listing.dart';
import '../services/book_service.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class BrowseListingsScreen extends StatelessWidget {
  final bool showBackButton;

  const BrowseListingsScreen({super.key, this.showBackButton = false});

  Future<void> _initiateSwap(BuildContext context, BookListing book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to make a swap offer')),
      );
      return;
    }

    if (user.uid == book.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot swap your own book')),
      );
      return;
    }

    try {
      await context.read<AppState>().createSwapOffer(book, book.userId, book.userName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap offer sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookService = BookService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Browse Listings'),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: StreamBuilder<List<BookListing>>(
        stream: bookService.getBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final allBooks = snapshot.data ?? [];
          final books = allBooks.where((book) => book.status == 'available').toList();

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'No books available yet.\nBe the first to post one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.textLight),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final isMyBook = user?.uid == book.userId;

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
                        child: book.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  book.imageUrl!,
                                  fit: BoxFit.cover,
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
                              book.title,
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
                              book.author,
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
                                    color: AppTheme.yellowAccent.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    book.condition,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  book.timeAgo,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                            if (!isMyBook) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _initiateSwap(context, book),
                                      icon: const Icon(Icons.swap_horiz, size: 18),
                                      label: const Text('Swap'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.yellowAccent,
                                        foregroundColor: AppTheme.textDark,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              otherUserId: book.userId,
                                              otherUserName: book.userName,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.chat, size: 18),
                                      label: const Text('Chat'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.darkBlue,
                                        side: const BorderSide(color: AppTheme.darkBlue),
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
}
