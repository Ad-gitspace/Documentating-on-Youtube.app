import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/youtube/v3.dart' as youtube;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'firebase_service.dart';
import '../core/models/user_settings.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      youtube.YouTubeApi.youtubeUploadScope,
      youtube.YouTubeApi.youtubeReadonlyScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> _handleFirebaseLinking(GoogleSignInAccount account) async {
    try {
      final GoogleSignInAuthentication googleAuth = await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final settings = await FirebaseService().fetchUserSettings();
      if (settings == null) {
        await FirebaseService().saveUserSettings(
          const UserSettings(
            defaultTitle: 'DocsMe Upload',
            defaultDescription: 'Uploaded via DocsMe App',
            autoUploadEnabled: false,
            preferredPrivacy: 'private',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error linking with Firebase: $e');
      // We log the error but don't rethrow, to prevent the app from getting stuck
      // if Firebase Firestore hasn't been initialized yet on the console.
    }
  }

  /// Initializes the service by attempting a silent login.
  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
    });
    _currentUser = await _googleSignIn.signInSilently();
    if (_currentUser != null) {
      await _handleFirebaseLinking(_currentUser!);
    }
  }

  /// Prompts the user to sign in using Google.
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        await _handleFirebaseLinking(account);
      }
      return account;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return null;
    }
  }

  /// Signs the user out.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.disconnect();
    _currentUser = null;
  }

  Future<auth.AuthClient?> getAuthenticatedClient() async {
    if (_currentUser == null) return null;
    
    final scopes = [
      youtube.YouTubeApi.youtubeUploadScope,
      youtube.YouTubeApi.youtubeReadonlyScope,
    ];

    bool canAccess = false;
    try {
      canAccess = await _googleSignIn.canAccessScopes(scopes);
    } catch (e) {
      debugPrint('canAccessScopes not implemented or failed: $e');
      // Fallback: If we can't check, we might just try to request them 
      // or assume we have them if we just signed in.
      // For safety, we can try to requestScopes which is more widely supported
      // and will be a no-op if already granted on most platforms.
    }

    if (!canAccess) {
      try {
        final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
        if (!isAuthorized) return null;
      } catch (e) {
        debugPrint('Error requesting scopes: $e');
        // If requestScopes also fails, we might still try to get the client
        // but it will likely fail later if scopes are missing.
      }
    }

    return await _googleSignIn.authenticatedClient();
  }
}
