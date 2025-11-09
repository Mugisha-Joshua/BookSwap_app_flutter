import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> sendMessage(ChatMessage message, String otherUserId) async {
    await _firestore
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .add(message.toMap());

    // Update chat metadata with both participants
    await _firestore.collection('chats').doc(message.chatId).set({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp.toIso8601String(),
      'participants': [message.senderId, otherUserId],
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return <String, dynamic>{
                'chatId': doc.id,
                'lastMessage': data['lastMessage'] ?? '',
                'lastMessageTime': data['lastMessageTime'],
              };
            }).toList());
  }
}

