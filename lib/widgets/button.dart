import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String imageAsset;
  final String title;
  final Function onPressed;

  Button({this.title, this.imageAsset, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Color(0xffefeeff),
          boxShadow: [
            BoxShadow(
                color: Color(0XFFe1dffe),
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
              height: 30,
              width: 30,
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
