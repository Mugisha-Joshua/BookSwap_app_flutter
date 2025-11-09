import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadBookCover(XFile imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'book_covers/${user.uid}_$timestamp.jpg';
      
      final ref = _storage.ref().child(fileName);
      
      UploadTask uploadTask;
      
      // For web, read as bytes; for mobile, use File
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        uploadTask = ref.putFile(
          File(imageFile.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      
      // Wait for upload to complete with timeout
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Upload timeout'),
      );
      
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed');
      }
      
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBookCover(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting
    }
  }
}
