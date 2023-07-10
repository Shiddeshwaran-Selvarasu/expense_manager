import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginProvider extends ChangeNotifier {

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

  void logout() async {
    FirebaseAuth.instance.signOut();
  }
}
