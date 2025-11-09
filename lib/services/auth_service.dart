import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      
      if (kIsWeb) {
        // Web: Use popup sign-in
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'emailVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      // Error signing in with email
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name first
        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        
        // Send email verification with custom action code settings
        final actionCodeSettings = ActionCodeSettings(
          url: 'https://bookswap-71e05.firebaseapp.com/__/auth/action',
          handleCodeInApp: false,
          androidPackageName: 'com.example.bookswap',
          androidInstallApp: false,
          androidMinimumVersion: '12',
        );
        
        await userCredential.user!.sendEmailVerification(actionCodeSettings);
        
        // Reload user to get updated info
        await userCredential.user!.reload();
        final updatedUser = _auth.currentUser;
        
        // Create user document in Firestore
        if (updatedUser != null) {
          await _firestore.collection('users').doc(updatedUser.uid).set({
            'email': updatedUser.email,
            'displayName': displayName.isNotEmpty ? displayName : updatedUser.displayName,
            'emailVerified': updatedUser.emailVerified,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore Google sign out errors if user didn't sign in with Google
    }
    await _auth.signOut();
  }

  Future<void> updateUserName(String userId, String name) async {
    await _firestore.collection('users').doc(userId).set({
      'name': name,
    }, SetOptions(merge: true));
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://bookswap-71e05.firebaseapp.com/__/auth/action',
        handleCodeInApp: false,
        androidPackageName: 'com.example.bookswap',
        androidInstallApp: false,
        androidMinimumVersion: '12',
      );
      
      await user.sendEmailVerification(actionCodeSettings);
    }
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
