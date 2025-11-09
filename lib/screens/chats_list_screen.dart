import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatelessWidget {
  final bool showBackButton;

  const ChatsListScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final chatService = ChatService();
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: const Center(
          child: Text('Please sign in to view chats'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text('Chats'),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getUserChats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'No chats yet.\nStart a conversation by tapping on a book listing!',
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
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat['chatId'] as String;
              final lastMessage = chat['lastMessage'] as String? ?? '';
              
              // Extract the other user's ID from chatId
              final participants = chatId.split('_');
              final otherUserId = participants[0] == user.uid 
                  ? participants[1] 
                  : participants[0];

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  final otherUserName = userSnapshot.data?.get('displayName') as String? ?? 
                                       userSnapshot.data?.get('name') as String? ?? 
                                       'Unknown User';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.darkBlue.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      title: Text(
                        otherUserName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      subtitle: Text(
                        lastMessage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              otherUserId: otherUserId,
                              otherUserName: otherUserName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

