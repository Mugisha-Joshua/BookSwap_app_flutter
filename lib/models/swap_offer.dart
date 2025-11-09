import 'package:cloud_firestore/cloud_firestore.dart';

class SwapOffer {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookImageUrl;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String status; // 'pending', 'accepted', 'rejected', 'completed'
  final DateTime createdAt;
  final DateTime? updatedAt;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookImageUrl,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookImageUrl': bookImageUrl,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory SwapOffer.fromMap(String id, Map<String, dynamic> map) {
    Timestamp createdAt = map['createdAt'] as Timestamp? ?? Timestamp.now();
    Timestamp? updatedAt = map['updatedAt'] as Timestamp?;
    return SwapOffer(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      bookAuthor: map['bookAuthor'] ?? '',
      bookImageUrl: map['bookImageUrl'],
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      recipientId: map['recipientId'] ?? '',
      recipientName: map['recipientName'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }
}

