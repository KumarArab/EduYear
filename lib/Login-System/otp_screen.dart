import 'package:app/Provider/login_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/textbox.dart';

class OtpScreen extends StatelessWidget {
  TextEditingController otp = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final otpState = Provider.of<LoginStore>(context);
    return Scaffold(
      key: otpState.otpScaffoldKey,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextBox(
                phoneNo: otp,
                hintText: "Enter OTP here",
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Button(
                  title: "Confirm",
                  imageAsset: "assets/img/otp.png",
                  onPressed: () async {
                    await otpState.getCodeWithPhoneNumber(context, otp.text);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
