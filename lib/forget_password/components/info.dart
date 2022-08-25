import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_share_app/account_check/account_check.dart';
import 'package:photo_share_app/log_in/login_screen.dart';
import 'package:photo_share_app/sign_up/sign_up_screen.dart';
import 'package:photo_share_app/widgets/button_square.dart';
import 'package:photo_share_app/widgets/input_field.dart';

class Credentials extends StatelessWidget {
  // const Credentials({Key? key}) : super(key: key);
  final TextEditingController _emailTextController =
      TextEditingController(text: '');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Center(
              child: Image.asset(
                "lib/images/forget.png",
                width: 300.0,
              ),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          InputField(
            hintText: "Enter Email",
            icon: Icons.email_rounded,
            obscureText: false,
            textEditingController: _emailTextController,
          ),
          const SizedBox(
            height: 10,
          ),
          ButtonSquare(
            text: "Send Link",
            colors1: Colors.red,
            colors2: Colors.redAccent,
            press: () async {
              try {
                await _auth.sendPasswordResetEmail(
                    email: _emailTextController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.amber,
                    content: Text(
                      "Password reset email has been sent!",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              } on FirebaseAuthException catch (error) {
                Fluttertoast.showToast(
                  msg: error.toString(),
                );
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SignUpScreen(),
                ),
              );
            },
            child: const Center(
              child: Text(
                'Create Account',
              ),
            ),
          ),
          AccountCheck(
            login: false,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
