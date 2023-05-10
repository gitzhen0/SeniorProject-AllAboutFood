import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  const LoadingScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(
              color: Colors.black,
            ),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}
