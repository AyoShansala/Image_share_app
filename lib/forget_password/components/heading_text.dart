import 'package:flutter/material.dart';

class HeadText extends StatelessWidget {
  const HeadText({Key? key}) : super(key: key);

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
            height: size.height * 0.06,
          ),
          const Center(
            child: Text(
              "Forget password",
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
              "Reset Here",
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
