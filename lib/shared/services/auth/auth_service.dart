import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/state_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> preLogOut(bool isPreLoggedOut) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("isPreLoggedOut", isPreLoggedOut).then((bool success) {});
  }

  Future<FirebaseUser> getCurrentUser() {
    return _auth.currentUser();
  }

  Future<void> singOut() {
    return _auth.signOut();
  }

  Future<AuthResult> signInWithPhoneNumber(
    String verificationId,
    String code,
  ) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: code);

    final user = await _auth.signInWithCredential(credential);
    return user;
  }

  Future<void> verifyPhone(
    String phoneNumber, {
    void Function(AuthResult) onLoginSucessful,
    void Function(String, [int]) codeSent,
    void Function(AuthException) verificationFailed,
    void Function(String) codeAutoRetrievalTimeout,
  }) {
    const duration = const Duration(seconds: 60);
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: duration,
      codeSent: codeSent,
      verificationFailed: verificationFailed,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      verificationCompleted: (credentials) async {
        try {
          final user = await _auth.signInWithCredential(credentials);
          onLoginSucessful(user);
        } catch (e) {}
      },
    );
  }

  Future<AuthResult> registerUser(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> forgetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    if (googleUser == null) throw FormatException('Cancelled');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<AuthResult> loginWithFacebook() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        throw FormatException('Cancelled');
        break;
      case FacebookLoginStatus.error:
        throw FormatException(result.errorMessage);
        break;
      default:
        break;
    }
    final fbAuthCredential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token);
    return _auth.signInWithCredential(fbAuthCredential);
  }

  Future<AuthResult> loginAnonymously() {
    return _auth.signInAnonymously();
  }

  static Future<bool> appleSignInAvailable() async {
    return AppleSignIn.isAvailable();
  }

  Future<AuthResult> logInWithApple() async {
    // 1. perform the sign-in request
    final result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);
    final appleIdCredential = result.credential;
    final oAuthProvider = OAuthProvider(providerId: 'apple.com');
    final credential = oAuthProvider.getCredential(
      idToken: String.fromCharCodes(appleIdCredential.identityToken),
      accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
    );
    print(result.status);
    return _auth.signInWithCredential(credential);

    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.error:
        throw FormatException(result.error.toString());

      case AuthorizationStatus.cancelled:
        throw FormatException('Cancelled');
        break;
      default:
        break;
    }
  }
}
