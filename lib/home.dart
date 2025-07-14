import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottomSheetModal.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => BottomSheetModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          // ignore: prefer_const_literals_to_create_immutables
          gradient: LinearGradient(
              colors: [Color(0XFFf5f5f5), Color(0XFFf5f5f5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/odo.png",
              height: 250,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 16,
            ),
            CupertinoButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              color: Colors.black,
              child: const Text(
                "LOGIN",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            CupertinoButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              color: Colors.black,
              child: const Text(
                "SIGN UP",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
