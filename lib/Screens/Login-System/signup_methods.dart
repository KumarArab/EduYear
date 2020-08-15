import 'dart:ui';
import 'package:app/Provider/login_store.dart';
import 'package:app/Screens/Login-System/phone_login.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/widgets/button.dart';

class SignUpMethods extends StatefulWidget {
  @override
  _SignUpMethodsState createState() => _SignUpMethodsState();
}

class _SignUpMethodsState extends State<SignUpMethods> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final loginState = Provider.of<LoginStore>(context);
    return Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: Stack(
                  children: [
                    Container(
                      color: Color(0xffefeeff),
                    ),
                    Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: double.infinity,
                          child: Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                padding: EdgeInsets.all(50),
                                child: Image.asset(
                                    Provider.of<LoginStore>(context)
                                        .images[index]),
                              );
                            },
                            itemCount: 3,
                            autoplay: true,
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: double.infinity,
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Color(0xfffefefe),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.6,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.08,
                                    width: double.infinity,
                                    child: Swiper(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          child: Text(
                                            '"' +
                                                Provider.of<LoginStore>(context)
                                                    .caption[index] +
                                                '"',
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontFamily: "MarckScript",
                                                color: Colors.black),
                                          ),
                                        );
                                      },
                                      itemCount: 3,
                                      autoplay: true,
                                    ),
                                  ),
                                  Divider(),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "SignUp / LogIn",
                                            style: TextStyle(
                                                fontSize: 35,
                                                fontFamily: "Poppins",
                                                color: Colors.black87),
                                          ),
                                          Column(
                                            children: [
                                              Button(
                                                imageAsset:
                                                    "assets/img/phone-call.png",
                                                title: "Phone Number",
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              LoginScreen()));
                                                },
                                              ),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              Button(
                                                imageAsset:
                                                    "assets/img/google.png",
                                                title: "Google",
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  loginState.signInWithGoogle(
                                                      context);
                                                },
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "facing any problems?? contact us",
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.black54,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ));
  }
}
