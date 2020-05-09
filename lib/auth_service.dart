import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

//Singleton
class AuthService {
  static final AuthService _instance = AuthService._internal();

  Stream<FirebaseUser> get authState => _auth.onAuthStateChanged.skip(1);

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _auth = FirebaseAuth.instance;
  }

  FirebaseAuth _auth;

  String userEmail;
  String firstName;

  void clearData() {
    userEmail = null;
    firstName = null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  Future<FirebaseUser> signInWithFb() async {
    var instance = FacebookLogin();

    var result = await instance.logIn(['email']);

    print(result.status);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        var token = result.accessToken;

        AuthCredential credential =
            FacebookAuthProvider.getCredential(accessToken: token.token);

        final response = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token.token}',
        );

        Map profile = jsonDecode(response.body);

        userEmail = profile['email'];
        firstName = profile['first_name'];

        AuthResult authResult = await _auth.signInWithCredential(credential);

        return authResult.user;

        break;

      case FacebookLoginStatus.cancelledByUser:
        break;

      case FacebookLoginStatus.error:
        throw PlatformException(code: 'Unknown');
        break;
    }
    return null;
  }

  Future<FirebaseUser> signInWithGmail() async {
    var googleAccount = await GoogleSignIn(scopes: ['email']).signIn();

    if (googleAccount == null) return null; //process canceled by the user

    userEmail = googleAccount.email;

    var gAuth = await googleAccount.authentication;

    AuthCredential authCredential = GoogleAuthProvider.getCredential(
      idToken: gAuth.idToken,
      accessToken: gAuth.accessToken,
    );

    AuthResult result = await _auth.signInWithCredential(authCredential);

    return result.user;
  }
}
