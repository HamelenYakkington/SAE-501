import 'package:flutter/material.dart';
import 'package:sae_501/controller/deco_controller.dart';

class LogOut extends StatefulWidget {
  @override
  _Logout createState() => _Logout();
}

class _Logout extends State<LogOut> {
  @override
  void initState() {
    super.initState();
    _logOutUser();
  }

  Future<void> _logOutUser() async {
    
    await deco(context);
    await Future.delayed(Duration(seconds: 2));

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
