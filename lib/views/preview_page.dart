import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PreviewPage  extends StatefulWidget {
  const PreviewPage({
    Key? key,
    required this.picture,
    required this.pictureName
  }) : super(key: key);

  final Image picture;
  final String pictureName;

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {

  FocusNode focusEmojiTextField = FocusNode();

  TextEditingController captionMessageController = new TextEditingController();

  @override
  void dispose() {
    focusEmojiTextField.dispose();
    captionMessageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

   pressedCaptionField() {
    print("pressed caption field");
    focusEmojiTextField.requestFocus();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
      Expanded(
      child: SingleChildScrollView(
      reverse: true,
          child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(height: 20),
            widget.picture,
            SizedBox(height: 20),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Color(0x36FFFFFF),
                      borderRadius: BorderRadius.circular(35)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          child: Form(
                            child: TextFormField(
                              focusNode: focusEmojiTextField,
                              onTap: () {
                                pressedCaptionField();
                              },
                              controller: captionMessageController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintText: "Add a caption...",
                                  hintStyle:
                                  TextStyle(color: Colors.white54),
                                  border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print("test");
                        },
                        child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                color: Color(0xFF34A843),
                                borderRadius: BorderRadius.circular(35)),
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
      ),
      ]
      ),
    );
  }
}