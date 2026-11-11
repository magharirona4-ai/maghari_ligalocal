import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'store.dart';

/// true  = new users must open the link in their email first (Verify Email screen)
/// false = skip email verification (easier while you are testing)
const bool requireEmailVerification = false;

/// Real login using Firebase. The user's profile is saved in Firestore: users/{uid}.
/// Everyone starts as a Player. Someone who picks "Organizer" at sign up
/// is a Player with organizerRequest = 'pending' until an organizer approves.
class AuthState extends ChangeNotifier {
  AuthState() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  bool isLoggedIn = false;
  bool isEmailVerified = false;
  String role = 'player'; // 'player' or 'organizer'
  String organizerRequest = 'none'; // none / pending / approved / declined
  String fullName = '';
  String email = '';

  bool _signingUp = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  bool get isOrganizer => role == 'organizer';
  bool get organizerPending => !isOrganizer && organizerRequest == 'pending';

  String get firstName {
    final n = fullName.trim();
    return n.isEmpty ? 'there' : n.split(' ').first;
  }

  // Runs when the app starts and whenever someone logs in or out.
  Future<void> _onAuthChanged(User? user) async {
    if (_signingUp) return; // signUp() will set everything itself
    if (user == null) {
      _profileSub?.cancel();
      _profileSub = null;
      isLoggedIn = false;
      isEmailVerified = false;
      role = 'player';
      organizerRequest = 'none';
      fullName = '';
      email = '';
      store.stop();
      notifyListeners();
      return;
    }
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data();
      role = (data?['role'] as String?) ?? 'player';
      organizerRequest = (data?['organizerRequest'] as String?) ?? 'none';
      fullName = (data?['fullName'] as String?) ?? (user.displayName ?? '');
    } catch (_) {
      // no internet or no profile yet: keep the defaults
    }
    email = user.email ?? '';
    isEmailVerified = !requireEmailVerification || user.emailVerified;
    isLoggedIn = true;
    store.start();
    _watchProfile(user.uid);
    notifyListeners();
  }

  // Keeps role / approval status up to date while the app is open.
  void _watchProfile(String uid) {
    _profileSub?.cancel();
    _profileSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      final d = snap.data();
      if (d == null) return;
      final newRole = (d['role'] as String?) ?? 'player';
      final newRequest = (d['organizerRequest'] as String?) ?? 'none';
      final newName = (d['fullName'] as String?) ?? fullName;
      if (newRole != role || newRequest != organizerRequest || newName != fullName) {
        role = newRole;
        organizerRequest = newRequest;
        fullName = newName;
        notifyListeners();
      }
    }, onError: (Object e) {});
  }

  /// Returns null when OK, or an error message to show.
  /// [role] is what the person asked for. 'organizer' becomes a pending request.
  Future<String?> signUp({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String role,
  }) async {
    _signingUp = true;
    final wantsOrganizer = role == 'organizer';
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim(), password: password);
      final user = cred.user!;
      await user.updateDisplayName(fullName.trim());
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'username': username.trim(),
        'role': 'player',
        'organizerRequest': wantsOrganizer ? 'pending' : 'none',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (requireEmailVerification) {
        await user.sendEmailVerification();
      }
      this.role = 'player';
      organizerRequest = wantsOrganizer ? 'pending' : 'none';
      this.fullName = fullName.trim();
      this.email = email.trim();
      isEmailVerified = !requireEmailVerification || user.emailVerified;
      isLoggedIn = true;
      _signingUp = false;
      store.start();
      _watchProfile(user.uid);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _signingUp = false;
      return _message(e.code);
    } catch (e) {
      _signingUp = false;
      await FirebaseAuth.instance.signOut();
      return 'Could not save your profile. Check your internet and try again.';
    }
  }


  /// Sign in with the Google provider configured in Firebase Authentication.
  Future<String?> signInWithGoogle() async {
    try {
      await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return 'Google sign-in could not be completed. Check your Firebase provider setup and internet connection.';
    }
  }

  /// Sign in with the Facebook provider configured in Firebase Authentication.
  Future<String?> signInWithFacebook() async {
    try {
      await FirebaseAuth.instance.signInWithProvider(FacebookAuthProvider());
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return 'Facebook sign-in could not be completed. Check your Firebase provider setup and internet connection.';
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Update the signed-in user's display name and Firestore profile.
  Future<String?> updateName(String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'You must be logged in.';

      final name = newName.trim();
      if (name.isEmpty) return 'Name cannot be empty.';

      await user.updateDisplayName(name);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fullName': name,
      });

      fullName = name;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return 'Could not update your name. Please try again.';
    }
  }

  /// Change password after verifying the user's current password.
  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        return 'You must be logged in.';
      }
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        return 'Please fill in all password fields.';
      }
      if (newPassword.length < 6) {
        return 'New password must be at least 6 characters.';
      }
      if (currentPassword == newPassword) {
        return 'Your new password must be different.';
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Your current password is incorrect.';
      }
      if (e.code == 'requires-recent-login') {
        return 'Please log in again before changing your password.';
      }
      return _message(e.code);
    } catch (_) {
      return 'Could not change your password. Please try again.';
    }
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();

  Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Used by the Verify Email screen (only when requireEmailVerification is true).
  Future<String?> checkEmailVerified() async {
    final u = FirebaseAuth.instance.currentUser;
    await u?.reload();
    final fresh = FirebaseAuth.instance.currentUser;
    if (fresh != null && fresh.emailVerified) {
      isEmailVerified = true;
      notifyListeners();
      return null;
    }
    return 'Not verified yet. Open the link in your email, then tap the button again.';
  }

  Future<void> resendVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  static String _message(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'That email is already registered. Try logging in.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many tries. Please wait a moment and try again.';
      default:
        return 'Something went wrong ($code).';
    }
  }
}

final auth = AuthState();
