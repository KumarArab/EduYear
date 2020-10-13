import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String imageAsset;
  final String title;
  final Function onPressed;

  Button({this.title, this.imageAsset, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      height: deviceHeight * 0.08,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.teal.withOpacity(0.2),
          boxShadow: [
            BoxShadow(
                color: Colors.teal.withOpacity(0.2),
                offset: Offset(6, 2),
                blurRadius: 1.0,
                spreadRadius: 2.0),
          ]),
      child: FlatButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: deviceHeight * 0.04,
              width: deviceHeight * 0.04,
              child: Image.asset(imageAsset),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: TextStyle(
                  fontFamily: "Poppins", color: Colors.black87, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}

// Neomorphic Textbox
