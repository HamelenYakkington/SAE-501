import 'package:flutter/material.dart';
import 'package:sae_501/controller/deco_controller.dart';

class LogOut extends StatefulWidget {

  const LogOut({Key? key}) : super(key: key);

  @override
  LogoutState createState() => LogoutState();
}

class LogoutState extends State<LogOut> {
  @override
  void initState() {
    super.initState();
    _logOutUser();
  }

  Future<void> _logOutUser() async {
    
    await deco(context);
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
