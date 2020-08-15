import 'package:app/Provider/login_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/button.dart';
import '../../widgets/textbox.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneNo = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStore>(context);
    return Scaffold(
      key: loginState.loginScaffoldKey,
      body: Container(
        color: Color(0xffefeeff),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Image.asset(
                  ("assets/img/loginphone.png"),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: 'We will send you an ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontFamily: "Poppins",
                            ),
                          ),
                          TextSpan(
                            text: 'One Time Password ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          TextSpan(
                            text: 'on this mobile number',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ]),
                      ),
                      TextBox(
                        phoneNo: phoneNo,
                        hintText: "  Enter in [+91] format",
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Button(
                          title:
                              isLoading ? "Please Wait....." : "Login / SignUp",
                          imageAsset: "assets/img/phone-call.png",
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await loginState
                                .getCodeWithPhoneNumber(context, phoneNo.text)
                                .then((_) {
                              setState(() {
                                isLoading = false;
                              });
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
