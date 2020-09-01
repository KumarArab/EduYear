import 'package:flutter/material.dart';

InputDecoration setTextFieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: UnderlineInputBorder(borderSide: BorderSide.none),
  );
}

final BoxDecoration kTagContainerDecoration = BoxDecoration(
  border: Border.all(),
  borderRadius: BorderRadius.circular(100),
);
