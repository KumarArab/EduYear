import 'package:flutter/material.dart';

class TextBox extends StatelessWidget {
  final TextEditingController phoneNo;
  final String hintText;
  final TextInputType keyboardType;

  TextBox({this.phoneNo, this.hintText, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.only(top: 20, bottom: 30),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(100), boxShadow: [
        BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(6, 2),
            blurRadius: 6.0,
            spreadRadius: 3.0),
        BoxShadow(
            color: Color.fromRGBO(255, 255, 255, 0.9),
            offset: Offset(-6, -2),
            blurRadius: 6.0,
            spreadRadius: 3.0)
      ]),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(fontFamily: "Poppins"),
        ),
        controller: phoneNo,
      ),
    );
  }
}
