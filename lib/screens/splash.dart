import "dart:async";

import "package:flutter/material.dart";
import "package:project/screens/login.dart";

class Splash extends StatefulWidget {
  @override
  _splash createState() => _splash();
}

class _splash extends State<Splash> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.blue,

      body: Container(
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(height: 170),
            Container(child: Image.asset("pic.png", width: 350, height: 300)),
            Center(
              child: Text(
                "Buy and Sell Properties",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
