import 'package:app/Provider/login_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../widgets/button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // UserProvider userProvider;

  // @override
  // void initState() {
  //   SchedulerBinding.instance.addPostFrameCallback((_) {
  //     userProvider = Provider.of<UserProvider>(context, listen: false);

  //     userProvider.refreshUser();
  //   });
  //   super.initState();
  // }

  // @override
  // void didChangeDependencies() {
  //   // Provider.of<LoginStore>(context).saveUserInfo();
  //   Provider.of<LoginStore>(context, listen: true).fetchDetails();
  //   // Provider.of<LoginStore>(context).saveUserInfo();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final logindata = Provider.of<LoginStore>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            Text(logindata.username != null ? logindata.username : "No Data"),
        actions: [
          FlatButton.icon(
            label: Text(
              "Log Out",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: Icon(Icons.cancel, color: Colors.white),
            onPressed: () {
              Provider.of<LoginStore>(context, listen: false).signOut(context);
            },
          )
        ],
      ),
      body: Center(
        child: Icon(Icons.ac_unit),
      ),
    );
  }
}
