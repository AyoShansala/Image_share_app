import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HeadText extends StatelessWidget {
  const HeadText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 15.0,
      ),
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.05,
          ),
          const Center(
            child: Text(
              "PhotoSharing",
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          const Center(
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
