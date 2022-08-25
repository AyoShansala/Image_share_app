import 'package:flutter/material.dart';
import 'package:photo_share_app/forget_password/components/heading_text.dart';
import 'package:photo_share_app/forget_password/components/info.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink,
            Colors.deepOrange.shade300,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [
            0.2,
            0.9,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                HeadText(),
                Credentials(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
