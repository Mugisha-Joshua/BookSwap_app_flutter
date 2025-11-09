import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/swap_offer.dart';
import '../models/book_listing.dart';

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createSwapOffer(BookListing book, String recipientId, String recipientName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Create swap offer
    final offer = SwapOffer(
      id: '',
      bookId: book.id,
      bookTitle: book.title,
      bookAuthor: book.author,
      bookImageUrl: book.imageUrl,
      senderId: user.uid,
      senderName: user.displayName ?? 'Anonymous',
      recipientId: recipientId,
      recipientName: recipientName,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('swapOffers').add(offer.toMap());

    // Update book status to pending
    await _firestore.collection('books').doc(book.id).update({
      'status': 'pending',
    });
  }

  Stream<List<SwapOffer>> getMyOffers(String userId) {
    return _firestore
        .collection('swapOffers')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final offers = snapshot.docs
              .map((doc) => SwapOffer.fromMap(doc.id, doc.data()))
              .toList();
          offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return offers;
        });
  }

  Stream<List<SwapOffer>> getReceivedOffers(String userId) {
    return _firestore
        .collection('swapOffers')
        .where('recipientId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final offers = snapshot.docs
              .map((doc) => SwapOffer.fromMap(doc.id, doc.data()))
              .toList();
          offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return offers;
        });
  }

  Future<void> acceptOffer(String offerId, String bookId) async {
    final batch = _firestore.batch();

    // Update offer status
    batch.update(
      _firestore.collection('swapOffers').doc(offerId),
      {
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Update book status to swapped
    batch.update(
      _firestore.collection('books').doc(bookId),
      {
        'status': 'swapped',
      },
    );

    await batch.commit();
  }

  Future<void> rejectOffer(String offerId, String bookId) async {
    final batch = _firestore.batch();

    // Update offer status
    batch.update(
      _firestore.collection('swapOffers').doc(offerId),
      {
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Update book status back to available
    batch.update(
      _firestore.collection('books').doc(bookId),
      {
        'status': 'available',
      },
    );

    await batch.commit();
  }

  Future<void> respondToOffer(String offerId, bool accept) async {
    final offerDoc = await _firestore.collection('swapOffers').doc(offerId).get();
    if (!offerDoc.exists) throw Exception('Offer not found');
    
    final offerData = offerDoc.data()!;
    final bookId = offerData['bookId'] as String;
    
    if (accept) {
      await acceptOffer(offerId, bookId);
    } else {
      await rejectOffer(offerId, bookId);
    }
  }
}

