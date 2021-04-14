import 'package:flutter/material.dart';

class SpacebarKey extends StatelessWidget {

  const SpacebarKey({
    Key key,
    this.onSpacebar,
  }) : super(key: key);

  final VoidCallback onSpacebar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: (MediaQuery.of(context).size.width / 8)*3, // make it 8 buttons wide
        height: MediaQuery.of(context).size.width / 8, // make it square
        child: TextButton(
          onPressed: () {
            onSpacebar?.call();
          },
          child: Icon(Icons.space_bar)
        )
    );
  }
}