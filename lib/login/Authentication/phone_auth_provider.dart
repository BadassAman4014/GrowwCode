import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:growwcode/login/Authentication/phone_user_services.dart';
import '../../H2.dart';
import '../../Homepage.dart';
import '../welcome_screen.dart';



class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String smsOtp;
  late String verificationId;
  late String error;
  bool _isLoggedIn = false;

  UserServices _userServices = UserServices();

  bool get isLoggedIn => _isLoggedIn;

  Future<void> verifyPhone(BuildContext context, String phoneNumber) async {
    final PhoneVerificationCompleted verificationCompleted = (
        PhoneAuthCredential credential) async {
      await _auth.signInWithCredential(credential);
    };


    final PhoneVerificationFailed verificationFailed = (
        FirebaseAuthException e) {
      print(e.code);
    };

    final PhoneCodeSent smsOtpSend = (String verId, int ? resendToken) async {
      this.verificationId = verId;
      smsOtpDialog(context);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    }
    catch (e) {
      print(e);
    }
  }

  Future smsOtpDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('Verification Code'),
                SizedBox(height: 6,),
                Text('Enter 6 digit Code received by SMS',
                  style: TextStyle(color: Colors.grey, fontSize: 12),)
              ],
            ),
            content: Container(
              height: 85,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  this.smsOtp = value;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider
                        .credential(
                      verificationId: verificationId, smsCode: smsOtp,);

                    final User ? user = (await _auth.signInWithCredential(
                        phoneAuthCredential)).user;

                    // create user data in firestore after the user successfully registers
                    String id = user!.uid;
                    String number = user.phoneNumber!;
                    _createUser(id: id, number: number);
                    // navigate to homepage after login.
                    if (user != null) {
                      Navigator.of(context).pop();

                      // Set the state of login as true after login
                      _isLoggedIn = true;

                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => HomeScreen(language: 'en',), // Change to HomeScreen
                      ));
                    }
                    else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => WelcomePage(), // Change to HomeScreen
                      ));
                      print('Login Failed');
                    }
                  } catch (e) {
                    this.error = 'invalid OTP';
                    Navigator.of(context).pop();
                  }
                },
                child: Text('DONE'),
              ),
            ],
          );
        });
  }

  void logout(BuildContext context) {
    _auth.signOut().then((_) {
      // Set the state of login as false after logout
      _isLoggedIn = false;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => WelcomePage(),
      ));
    });
  }

  void _createUser({String? id, String? number}) {
    _userServices.createUserData({
      'id': id,
      'number': number,
    });
  }
}
