import 'package:cloud_firestore/cloud_firestore.dart';

class BookListing {
  final String id;
  final String title;
  final String author;
  final String swapFor;
  final String condition;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final String? imageUrl;
  final String status; // 'available', 'pending', 'swapped'

  BookListing({
    required this.id,
    required this.title,
    required this.author,
    required this.swapFor,
    required this.condition,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.imageUrl,
    this.status = 'available',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'swapFor': swapFor,
      'condition': condition,
      'userId': userId,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'status': status,
    };
  }

  factory BookListing.fromMap(String id, Map<String, dynamic> map) {
    Timestamp timestamp = map['createdAt'] as Timestamp? ?? Timestamp.now();
    return BookListing(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      swapFor: map['swapFor'] ?? '',
      condition: map['condition'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      createdAt: timestamp.toDate(),
      imageUrl: map['imageUrl'],
      status: map['status'] ?? 'available',
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

