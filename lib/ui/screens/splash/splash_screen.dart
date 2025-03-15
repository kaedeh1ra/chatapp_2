import 'dart:async';

import 'package:chatapp_2/core/constants/string.dart';
import 'package:chatapp_2/core/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.database});
  final Database database;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, wrapper);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            frame,
            height: 1.sh,
            width: 1.sw,
            fit: BoxFit.cover,
          ),
          Center(
            child: InkWell(
              onTap: () {
                AuthService().logout();
              },
              child: Image.asset(
                logo,
                height: 170,
                width: 170,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
