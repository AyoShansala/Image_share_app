import 'package:flutter/material.dart';

class HeadText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
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
                fontSize: 50,
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
              "Create Account",
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
