import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_share_app/account_check/account_check.dart';
import 'package:photo_share_app/forget_password/forget_password.dart';
import 'package:photo_share_app/home_screen/home_screen.dart';
import 'package:photo_share_app/sign_up/sign_up_screen.dart';
import 'package:photo_share_app/widgets/button_square.dart';
import 'package:photo_share_app/widgets/input_field.dart';

class Credentials extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailTextController =
      TextEditingController(text: "");
  final TextEditingController _passTextController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(35.0),
      child: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundImage: const AssetImage("lib/images/logo1.png"),
              backgroundColor: Colors.orange.shade600,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          InputField(
            hintText: "Enter Email",
            icon: Icons.email_rounded,
            obscureText: false,
            textEditingController: _emailTextController,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          InputField(
            hintText: "Enter Password",
            icon: Icons.lock,
            obscureText: true,
            textEditingController: _passTextController,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => ForgetPasswordScreen()),
                    ),
                  );
                },
                child: const Text(
                  "Forget Password?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              )
            ],
          ),
          ButtonSquare(
            text: "Login",
            colors1: Colors.red,
            colors2: Colors.redAccent,
            press: () async {
              try {
                await _auth.signInWithEmailAndPassword(
                  email: _emailTextController.text.trim().toLowerCase(),
                  password: _passTextController.text.trim(),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => HomeScreen()),
                  ),
                );
              } catch (error) {
                Fluttertoast.showToast(
                  msg: error.toString(),
                );
              }
            },
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          AccountCheck(
            login: true,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: ((context) => SignUpScreen()),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
