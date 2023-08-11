import 'package:flutter/material.dart';
import 'dart:async';

class Loading extends StatefulWidget {
  const Loading({Key? key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    // Delay for 3 seconds before navigating to home screen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF639843),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  angle: _controller.value * 2.0 * 3.1415,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/logo.png"),
                    radius: 100,
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Bill \$horts',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "Roboto-Black.ttf",
              ),
            ),

            SizedBox(height: 8),
            Text(
              'A NOT-FOR-PROFIT project',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: "Roboto-Black.ttf",
              ),
            ),
            Text(
              'atif@wisc.edu',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: "Roboto-Black.ttf",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
