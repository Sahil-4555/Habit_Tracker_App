import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/utils.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/screens/user_information_screen.dart';
import 'package:habit_tracker/services/auth_provider.dart';
import 'package:habit_tracker/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  String verificationId;
  final String phoneNumber;
  OtpScreen({super.key, required this.verificationId, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;
  int start = 30;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 35),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                        Container(
                          width: 200,
                          height: 200,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple.shade50,
                          ),
                          child: Image.asset(
                            "asset/image2.png",
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Verification",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Enter The OTP send To Your Phone Number",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Pinput(
                          length: 6,
                          showCursor: true,
                          defaultPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.purple.shade200,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onCompleted: (value) {
                            setState(
                              () {
                                otpCode = value;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: CustomButton(
                            text: "Verify",
                            onPressed: () {
                              if (otpCode != null) {
                                verifyOtp(context, otpCode!);
                              } else {
                                showSnackBar(context, "Enter 6-Digit Code");
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Didn't receive any code?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                        ),
                        // const SizedBox(height: 15),
                        // RichText(
                        //   text: TextSpan(
                        //     children: [
                        //       const TextSpan(
                        //         text: "Send OTP again in ",
                        //         style: TextStyle(
                        //             fontSize: 15, color: Colors.black38),
                        //       ),
                        //       TextSpan(
                        //         text: "00:$start",
                        //         style: const TextStyle(
                        //             fontSize: 15, color: Colors.red),
                        //       ),
                        //       const TextSpan(
                        //         text: " Sec",
                        //         style: TextStyle(
                        //             fontSize: 15, color: Colors.black38),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: resendOTP,
                          child: const Text(
                            'Resend New Code',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void StartTimer() {
    const onsec = Duration(seconds: 1);
    Timer timer = Timer.periodic(
      onsec,
      (timer) {
        if (start == 0) {
          setState(
            () {
              timer.cancel();
            },
          );
        } else {
          setState(() {
            start--;
          });
        }
        ;
      },
    );
  }

  void resendOTP() async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          widget.verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  void verifyOtp(BuildContext context, String userOtp) {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    authProv.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        //Check Whether User Exists in DB
        authProv.checkExistingUser().then(
          (value) async {
            if (value == true) {
              //User Exists in DB
              authProv.getDataFromFireStore().then((value) => authProv
                  .saveUserDataToSharedPreferences()
                  .then((value) => authProv.setSignIn().then(
                        (value) => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (route) => false),
                      )));
            } else {
              //New User
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInformationScreen()),
                  (route) => false);
            }
          },
        );
      },
    );
  }
}
