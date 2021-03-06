import 'package:app/Login-System/otp_screen.dart';
import 'package:app/Login-System/signup_methods.dart';
import 'package:app/Screens/home_screen.dart';
import 'package:app/helpers/user_data.dart';
import 'package:app/helpers/user_maintainance.dart';
import 'package:app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginStore with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  UserMaintainer userMaintainer = UserMaintainer();

  String actualCode;

  bool isLoginLoading = false;
  bool isOtpLoading = false;

  FirebaseUser firebaseUser;

  String username, email, uid, photourl, phone;
  GlobalKey<ScaffoldState> loginScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> otpScaffoldKey = GlobalKey<ScaffoldState>();

  CollectionReference collectionReference =
      Firestore.instance.collection("Users");

  List images = [
    "assets/img/manage.png",
    "assets/img/inventory.png",
    "assets/img/analyze.png",
  ];

  List caption = [
    "Ascend your business with a modern way of billing and management.",
    "Manage your Inventory directly with your smartphone",
    "Check out your stats and drive your business accordingly",
  ];

  Future<bool> isAlreadyAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserMaintainer userMaintainer = UserMaintainer();
    String userId = prefs.getString('user_id');
    if (userId != null) {
      DocumentSnapshot documentSnapshot =
          await Firestore.instance.collection("Users").document(userId).get();
      Map<String, dynamic> fetchedUserData = documentSnapshot.data;
      await userMaintainer.saveUserDataToLocal(fetchedUserData);
      return true;
    } else {
      return false;
    }
  }

  Future<void> getCodeWithPhoneNumber(
      BuildContext context, String phoneNumber) async {
    isLoginLoading = true;

    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential auth) async {
          await _auth.signInWithCredential(auth).then((AuthResult value) {
            if (value != null && value.user != null) {
              print('Authentication successful');
              onAuthenticationSuccessful(context, value);
            } else {
              loginScaffoldKey.currentState.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
                content: Text(
                  'Invalid code/invalid authentication',
                  style: TextStyle(color: Colors.white),
                ),
              ));
            }
          }).catchError((error) {
            loginScaffoldKey.currentState.showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text(
                'Something has gone wrong, please try later',
                style: TextStyle(color: Colors.white),
              ),
            ));
          });
        },
        verificationFailed: (AuthException authException) {
          print('Error message: ' + authException.message);
          loginScaffoldKey.currentState.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              'The phone number format is incorrect. Please enter your number in E.164 format. [+][country code][number]',
              style: TextStyle(color: Colors.white),
            ),
          ));
          isLoginLoading = false;
        },
        codeSent: (String verificationId, [int forceResendingToken]) async {
          actualCode = verificationId;
          isLoginLoading = false;
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => OtpScreen()));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          actualCode = verificationId;
        });
  }

  Future<void> validateOtpAndLogin(BuildContext context, String smsCode) async {
    isOtpLoading = true;
    final AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: actualCode, smsCode: smsCode);

    await _auth.signInWithCredential(_authCredential).catchError((error) {
      isOtpLoading = false;
      otpScaffoldKey.currentState.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(
          'Wrong code ! Please enter the last code received.',
          style: TextStyle(color: Colors.white),
        ),
      ));
    }).then((AuthResult authResult) {
      if (authResult != null && authResult.user != null) {
        print('Authentication successful');
        onAuthenticationSuccessful(context, authResult);
      }
    });
  }

  Future<void> onAuthenticationSuccessful(
      BuildContext context, AuthResult result) async {
    isLoginLoading = true;
    isOtpLoading = true;

    firebaseUser = result.user;
    await userMaintainer.checkUserExistance(firebaseUser, context, "phone");

    isLoginLoading = false;
    isOtpLoading = false;
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await _googleSignIn.signOut();

    firebaseUser = null;

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => SignUpMethods()), (route) => false);
  }

  //SignUp/In with GOOGLE

  Future<void> signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    AuthResult authResult = await _auth.signInWithCredential(authCredential);

    firebaseUser = authResult.user;
    await userMaintainer.checkUserExistance(firebaseUser, context, "google");
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser = await _auth.currentUser();
    return currentUser;
  }
}
