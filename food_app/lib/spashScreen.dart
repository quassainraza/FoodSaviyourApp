import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_app/sign_in.dart';
//import 'sign_in.dart';
//import 'dart:async';

class SplashScreen extends StatelessWidget {
  static const routeName = 'route11';
  @override
  Widget build(BuildContext context) {
      Timer(Duration(seconds: 5), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (ctx) => SignIn()));
    });

    return Container(
      height: MediaQuery.of(context).size.height ,
      width: MediaQuery.of(context).size.width ,
      // child:Image.asset('image/bg.png',fit: BoxFit.cover,) ,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('image/logo.png'), fit: BoxFit.cover)),
    );
  }
}
