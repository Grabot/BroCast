import 'package:brocast/utils/utils.dart';
import 'package:flutter/material.dart';

class FindBros extends StatefulWidget {
  @override
  _FindBrosState createState() => _FindBrosState();
}

class _FindBrosState extends State<FindBros> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        style: TextStyle(
                            color: Colors.white
                        ),
                        decoration: InputDecoration(
                          hintText: "Search Bros...",
                          hintStyle: TextStyle(
                            color: Colors.white54
                          ),
                          border: InputBorder.none
                        ),
                      )
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                     gradient: LinearGradient(
                      colors: [
                          const Color(0x36FFFFFF),
                          const Color(0x0FFFFFFF)
                        ]
                      ),
                      borderRadius: BorderRadius.circular(40)
                    ),
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.search)
                  )
                ],
              ),
            )
          ],
        )
      )
    );
  }
}
