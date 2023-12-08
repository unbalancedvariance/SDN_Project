import 'dart:convert';

import 'package:flutterapp/utils/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_login/twitter_login.dart';

class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final twitterLogin = TwitterLogin(
      apiKey: Config.apikey_twitter,
      apiSecretKey: Config.secretkey_twitter,
      redirectURI: "sdnauth://");

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider,uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future SignInWithEmail() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // executing our authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // signing to firebase user instance
        final User? userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user;
        if (userDetails != null) {
          // now save all values
          _name = userDetails.displayName;
          _email = userDetails.email;
          _imageUrl = userDetails.photoURL;
          _imageUrl ??=
              "https://lh3.googleusercontent.com/a-/ALV-UjWTHr-LEPSwEj6jpItx8YE0LFu3nQbCvGdBFXI8M8E0k8c5qfhh5dQ9eumblOyIhHfTYPYb-Myz92PrbRIdWM4noHYQLhlxBZmecYNC7iRjnDQbf9asd9AimPTrPJayX5l6X4TkPCjq-WIwEI0EGSNgHpwhWOaODHrNUB0Ode1dHjgln3vJjUFofF2cjedpFmW0m6ZnE9ahPrVEQkoTK7c1RfORY-c7Kyp4RxkW2qaHS2LdbOrBtKRjDF32TNcg5GhMnLU4ADGX8XY888EyRPCuZVXCoczdd1F8-FXXYnatyh8tLRK3KWjK7C1Yr0krKgPNg4XKPw7hDgKQ4hV1u25WISoxRoYnc7QG1dOUmboumjRJnITnVwu_YsACRM4DqLQb5-rNrAnQW6KsFjHw4F0afSZxmyC57DiDteFowRRnD32V_eGdIl5BUNUKbZn1i88IndOSz-dM-ExWPNY4Kff-XfVcCM7ly9PqNJWjkP7h8N7Pqi7kcrDvEkgo0ExDFypscpQb2Wt_UuPpOcbOrWT4NMm-l3GXbNJtC3FJjJQiTNFXyMFmSbG6248MGKp5_OKr4plsyagDbODu0Dt_H9tbethEa9thp2eIyoLkQdGcTQiaNeSkB-tHs9AOnV92l6m0tfuUBdlNJxpIgi4_nXpDtf-HLFxo9mlHBnypExAVrt2x4wo0YHirBfDw5Dodq0d8nG11NO5I4GpexjtaTefVzCO5ncaCOJSPNm2No_onXHPKwRVLSMe9sZZj6xJWzBqIh_-4y7BWJhoT_nkJq9ssRoO5xaaAv40B7Q3O5kQq6k751CwTNaOjxcBSkc01RuRvJ6xAlc9wmtYPCiTt385LJ_40_Puc5RmIbj4ec8CONgfyRh8Q70TL14-tS1p5Wi79U-Y9pvuWcma9qpj6kjwO4mJ_V23y8Emul32ZbJ4Ndmw=s360-c-no";
          _provider = "GOOGLE";
          _uid = userDetails.uid;
          print(_name);
          print(_email);
          print(_imageUrl);
          print(_uid);
          notifyListeners();
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // sign in with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // executing our authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // signing to firebase user instance
        final User? userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user;
        if (userDetails != null) {
          // now save all values
          _name = userDetails.displayName;
          _email = userDetails.email;
          _imageUrl = userDetails.photoURL;
          _imageUrl ??=
              "https://lh3.googleusercontent.com/a-/ALV-UjWTHr-LEPSwEj6jpItx8YE0LFu3nQbCvGdBFXI8M8E0k8c5qfhh5dQ9eumblOyIhHfTYPYb-Myz92PrbRIdWM4noHYQLhlxBZmecYNC7iRjnDQbf9asd9AimPTrPJayX5l6X4TkPCjq-WIwEI0EGSNgHpwhWOaODHrNUB0Ode1dHjgln3vJjUFofF2cjedpFmW0m6ZnE9ahPrVEQkoTK7c1RfORY-c7Kyp4RxkW2qaHS2LdbOrBtKRjDF32TNcg5GhMnLU4ADGX8XY888EyRPCuZVXCoczdd1F8-FXXYnatyh8tLRK3KWjK7C1Yr0krKgPNg4XKPw7hDgKQ4hV1u25WISoxRoYnc7QG1dOUmboumjRJnITnVwu_YsACRM4DqLQb5-rNrAnQW6KsFjHw4F0afSZxmyC57DiDteFowRRnD32V_eGdIl5BUNUKbZn1i88IndOSz-dM-ExWPNY4Kff-XfVcCM7ly9PqNJWjkP7h8N7Pqi7kcrDvEkgo0ExDFypscpQb2Wt_UuPpOcbOrWT4NMm-l3GXbNJtC3FJjJQiTNFXyMFmSbG6248MGKp5_OKr4plsyagDbODu0Dt_H9tbethEa9thp2eIyoLkQdGcTQiaNeSkB-tHs9AOnV92l6m0tfuUBdlNJxpIgi4_nXpDtf-HLFxo9mlHBnypExAVrt2x4wo0YHirBfDw5Dodq0d8nG11NO5I4GpexjtaTefVzCO5ncaCOJSPNm2No_onXHPKwRVLSMe9sZZj6xJWzBqIh_-4y7BWJhoT_nkJq9ssRoO5xaaAv40B7Q3O5kQq6k751CwTNaOjxcBSkc01RuRvJ6xAlc9wmtYPCiTt385LJ_40_Puc5RmIbj4ec8CONgfyRh8Q70TL14-tS1p5Wi79U-Y9pvuWcma9qpj6kjwO4mJ_V23y8Emul32ZbJ4Ndmw=s360-c-no";
          _provider = "GOOGLE";
          _uid = userDetails.uid;
          print(_name);
          print(_email);
          print(_imageUrl);
          print(_uid);
          notifyListeners();
        }
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // sign in with twitter
  Future signInWithTwitter() async {
    final authResult = await twitterLogin.loginV2();

    if (authResult.status == TwitterLoginStatus.loggedIn) {
      try {
        final credential = TwitterAuthProvider.credential(
            accessToken: authResult.authToken!,
            secret: authResult.authTokenSecret!);
        await firebaseAuth.signInWithCredential(credential);

        final userDetails = authResult.user;
        // save all the data
        _name = userDetails!.name;
        _email = firebaseAuth.currentUser!.email;
        _imageUrl = userDetails.thumbnailImage;
        _uid = userDetails.id.toString();
        _provider = "TWITTER";
        _hasError = false;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // sign in with facebook
  Future signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login();
    // getting the profile
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'));

    final profile = jsonDecode(graphResponse.body);

    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await firebaseAuth.signInWithCredential(credential);
        // saving the values
        _name = profile['name'];
        _email = profile['email'];
        _imageUrl = profile['picture']['data']['url'];
        _uid = profile['id'];
        _hasError = false;
        _provider = "FACEBOOK";
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // ENTRY FOR CLOUDFIRESTORE
  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _uid = snapshot['uid'],
              _name = snapshot['name'],
              _email = snapshot['email'],
              _imageUrl = snapshot['image_url'],
              _provider = snapshot['provider'],
            });
  }

  Future saveDataToFirestore() async {
    final DocumentReference r =
        FirebaseFirestore.instance.collection("users").doc(uid);
    await r.set({
      "name": _name,
      "email": _email,
      "uid": _uid,
      "image_url": _imageUrl,
      "provider": _provider,
    });
    notifyListeners();
  }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('name', _name!);
    await s.setString('email', _email!);
    await s.setString('uid', _uid!);
    await s.setString('image_url', _imageUrl!);
    await s.setString('provider', _provider!);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _name = s.getString('name');
    _email = s.getString('email');
    _imageUrl = s.getString('image_url');
    _uid = s.getString('uid');
    _provider = s.getString('provider');
    notifyListeners();
  }

  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // signout
  Future userSignOut() async {
    await firebaseAuth.signOut;
    await googleSignIn.signOut();
    await facebookAuth.logOut();

    _isSignedIn = false;
    notifyListeners();
    // clear all storage information
    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }

  void phoneNumberUser(User user, email, name) {
    _name = name;
    _email = email;
    _imageUrl =
        "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png";
    _uid = user.phoneNumber;
    _provider = "PHONE";
    notifyListeners();
  }
}
