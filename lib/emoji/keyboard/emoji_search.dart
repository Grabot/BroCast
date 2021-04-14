import 'package:flutter/material.dart';

class SearchKey extends StatelessWidget {

  const SearchKey({
    Key key,
    this.onSearch,
  }) : super(key: key);

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 8, // make it 8 buttons wide
        height: MediaQuery.of(context).size.width / 8, // make it square
        child: TextButton(
          onPressed: () {
            onSearch?.call();
          },
          child: Icon(Icons.search)
        )
    );
  }
}