import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/constants.dart';

class LoginProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  void _showToast(String text,bool isError) {
    String color = isError ? "#ff3333":"#4caf50";
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: isError ? Colors.red : Colors.green,
      webBgColor: color,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
    );
  }

  bool _isSigningIn = true;
  var test = 0;

  LoginProvider() {
    _isSigningIn = false;
  }

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool isSigningIn) {
    _isSigningIn = isSigningIn;
    notifyListeners();
  }

  Future login(String email,String password) async {
    var connectionStatus = await Connectivity().checkConnectivity();
    if(connectionStatus == ConnectivityResult.none){
      _showToast('No Internet! Check your connection',true);
      return;
    }
    isSigningIn = true;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _showToast('Identity Verified. Logging in..',false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showToast('No user found for the given email.',true);
      } else if (e.code == 'wrong-password') {
        _showToast('Wrong password',true);
      }
    }

    isSigningIn = false;
  }

  Future<void> googleLogIn() async{
    var connectionStatus = await Connectivity().checkConnectivity();
    if (connectionStatus == ConnectivityResult.none) {
      _showToast('No Internet! Check your connection', true);
      return;
    }

    final user;

    isSigningIn = true;
    if(kIsWeb){
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      user = await googleSignIn.signIn();

      if(user == null){
        isSigningIn = false;
        _showToast("SignIn failed!", true);
        return;
      }else{
        final googleAuth = await user.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        var snapshot = FirebaseFirestore.instance.collection('/users');
        snapshot.doc(user.email).get().then((value){
          if(!value.exists){
            snapshot.doc(user.email).set({
              'name' : user.displayName,
              'email' : user.email,
              'rooms' : FieldValue.arrayUnion([]),
              'profileImageUrl' : user.photoUrl ?? defaultProfileImage,
            }).catchError((e){
              _showToast(e,true);
            });
          } else {
            snapshot.doc(user.email).update({
              'name' : user.displayName,
              'email' : user.email,
              'rooms' : FieldValue.arrayUnion([]),
              'profileImageUrl' : user.photoUrl ?? defaultProfileImage,
            }).catchError((e){
              _showToast(e,true);
            });
          }
        });

        await FirebaseAuth.instance.signInWithCredential(credential);
        _showToast('Identity Verified. Logging in..', false);
      }
    }
    isSigningIn = false;
  }

  void logout() async {
    FirebaseAuth.instance.signOut();
  }
}
