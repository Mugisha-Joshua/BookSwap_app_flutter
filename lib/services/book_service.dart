import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_listing.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookListing>> getBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookListing.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addBook(BookListing book) async {
    await _firestore.collection('books').add(book.toMap());
  }

  Stream<List<BookListing>> getUserBooks(String userId) {
    return _firestore
        .collection('books')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final books = snapshot.docs
              .map((doc) => BookListing.fromMap(doc.id, doc.data()))
              .toList();
          // Sort by createdAt in memory to avoid composite index requirement
          books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return books;
        });
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }
}

