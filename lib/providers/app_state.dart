import 'package:flutter/material.dart';
import '../models/book_listing.dart';
import '../models/swap_offer.dart';
import '../services/book_service.dart';
import '../services/swap_service.dart';

class AppState extends ChangeNotifier {
  final SwapService _swapService = SwapService();
  
  List<BookListing> _books = [];
  List<SwapOffer> _myOffers = [];
  List<SwapOffer> _receivedOffers = [];
  bool _isLoading = false;

  List<BookListing> get books => _books;
  List<SwapOffer> get myOffers => _myOffers;
  List<SwapOffer> get receivedOffers => _receivedOffers;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void updateBooks(List<BookListing> books) {
    _books = books;
    notifyListeners();
  }

  void updateMyOffers(List<SwapOffer> offers) {
    _myOffers = offers;
    notifyListeners();
  }

  void updateReceivedOffers(List<SwapOffer> offers) {
    _receivedOffers = offers;
    notifyListeners();
  }

  Future<void> createSwapOffer(BookListing book, String recipientId, String recipientName) async {
    setLoading(true);
    try {
      await _swapService.createSwapOffer(book, recipientId, recipientName);
    } finally {
      setLoading(false);
    }
  }

  Future<void> respondToOffer(String offerId, bool accept) async {
    setLoading(true);
    try {
      await _swapService.respondToOffer(offerId, accept);
    } finally {
      setLoading(false);
    }
  }
}