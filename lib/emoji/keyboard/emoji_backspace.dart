import 'package:flutter/material.dart';

class BackspaceKey extends StatelessWidget {

  const BackspaceKey({
    Key key,
    this.onBackspace,
  }) : super(key: key);

  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 8, // make it 8 buttons wide
        height: MediaQuery.of(context).size.width / 8, // make it square
        child: TextButton(
            onPressed: () {
              onBackspace?.call();
            },
            child: Icon(Icons.backspace)
        )
    );
  }
}