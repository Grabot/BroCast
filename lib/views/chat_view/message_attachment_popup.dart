import 'package:flutter/material.dart';

abstract class MessageAttachmentPopupAction {
  const MessageAttachmentPopupAction();
}

class AttachmentOutsideClicked extends MessageAttachmentPopupAction {
  const AttachmentOutsideClicked();
}

class AttachmentGalleryClicked extends MessageAttachmentPopupAction {
  const AttachmentGalleryClicked();
}

class AttachmentCameraClicked extends MessageAttachmentPopupAction {
  const AttachmentCameraClicked();
}

class AttachmentMicClicked extends MessageAttachmentPopupAction {
  const AttachmentMicClicked();
}

class AttachmentLocationClicked extends MessageAttachmentPopupAction {
  const AttachmentLocationClicked();
}

class MessageAttachmentPopup extends StatefulWidget {
  final double yPosition;
  final bool showMediaPopup;
  final void Function(MessageAttachmentPopupAction) onAction;

  const MessageAttachmentPopup({
    required this.yPosition,
    required this.showMediaPopup,
    required this.onAction,
    Key? key,
  }) : super(key: key);

  @override
  MessageAttachmentPopupState createState() => MessageAttachmentPopupState();
}

class MessageAttachmentPopupState extends State<MessageAttachmentPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;


  Widget button(IconData icon, Color iconColor, String text, double buttonSize, double animationValue, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          width: buttonSize * animationValue,
          height: buttonSize * animationValue,
          decoration: BoxDecoration(
            color: Color(0xff1e202b),
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: onTap,
              child: Container(
                color: Colors.grey.withValues(alpha: 0.1),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: (buttonSize/2) * animationValue,
                ),
              ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0 * animationValue,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 50.0
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    if (widget.showMediaPopup) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant MessageAttachmentPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showMediaPopup != oldWidget.showMediaPopup) {
      if (widget.showMediaPopup) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double popupWidth = MediaQuery.of(context).size.width;
    popupWidth = (popupWidth / 4) * 3;
    double singleEntity = popupWidth / 5;
    double distanceFromSize = MediaQuery.of(context).size.width / 8;

    return Stack(
      children: [
        widget.showMediaPopup
            ? Positioned.fill(
          child: GestureDetector(
            onTap: () {
              widget.onAction(const AttachmentOutsideClicked());
            },
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        )
            : Container(),
        Positioned(
          bottom: (MediaQuery.of(context).size.height - widget.yPosition) + 30,
          right: distanceFromSize,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: popupWidth * _animation.value,
                height: singleEntity * 1.5 * _animation.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    button(Icons.collections, Colors.blue, 'Gallery', singleEntity, _animation.value, () {
                      widget.onAction(const AttachmentGalleryClicked());
                    }),
                    button(Icons.camera_alt, Colors.red, 'Camera', singleEntity, _animation.value, () {
                      widget.onAction(const AttachmentCameraClicked());
                    }),
                    button(Icons.mic, Colors.purple, 'Record', singleEntity, _animation.value, () {
                      widget.onAction(const AttachmentMicClicked());
                    }),
                    button(Icons.location_on, Colors.green, 'Location', singleEntity, _animation.value, () {
                      widget.onAction(const AttachmentLocationClicked());
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
