import 'package:app/Provider/login_store.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/textbox.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneNo = TextEditingController();
  bool isLoading = false;
  String code = "+91";

  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStore>(context);
    return Scaffold(
      key: loginState.loginScaffoldKey,
      body: Container(
        color: Colors.teal.withOpacity(0.2),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                decoration: const BoxDecoration(
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
                          const TextSpan(
                            text: 'We will send you an ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontFamily: "Poppins",
                            ),
                          ),
                          const TextSpan(
                            text: 'One Time Password ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          const TextSpan(
                            text: 'on this mobile number',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ]),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: TextField(
                          controller: phoneNo,
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Enter your phone number here",
                            prefix: CountryCodePicker(
                              onChanged: (val) {
                                code = val.toString();
                                print(code);
                              },
                              initialSelection: '+91',
                              favorite: ['+91'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                            ),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide.none),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                      ),
                      // TextBox(
                      //   phoneNo: phoneNo,
                      //   hintText: "  Enter in [+91] format",
                      //   keyboardType: TextInputType.phone,
                      // ),
                      Button(
                        title: isLoading ? "please wait" : "Login / SignUp",
                        imageAsset: "assets/img/phone-call.png",
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          String actualPhoneNo = "$code${phoneNo.text}";
                          print(actualPhoneNo);
                          await loginState.getCodeWithPhoneNumber(
                              context, actualPhoneNo);
                        },
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
