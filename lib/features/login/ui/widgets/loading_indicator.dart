import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
            width: 80,
            height: 30,
            child: CircularProgressIndicator(
              color: Colors.black.withOpacity(0.7),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: SizedBox(
              width: 80,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.black.withOpacity(0.05),
              )),
        ),
      ],
    );

  }
}
