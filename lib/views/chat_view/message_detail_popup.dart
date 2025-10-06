import 'package:flutter/material.dart';

import '../../objects/message.dart';

abstract class MessagePopupAction {
  final Message message;
  const MessagePopupAction({
    required this.message
  });
}

class MessageBroPopupAction extends MessagePopupAction {
  final int broId;
  const MessageBroPopupAction({
    required this.broId,
    required super.message
  });
}

class AddNewBroPopupAction extends MessagePopupAction {
  final int broId;
  const AddNewBroPopupAction({
    required this.broId,
    required super.message
  });
}

class MakeBroAdminPopupAction extends MessagePopupAction {
  final int broId;
  const MakeBroAdminPopupAction({
    required this.broId,
    required super.message
  });
}

class DismissBroAdminPopupAction extends MessagePopupAction {
  final int broId;
  const DismissBroAdminPopupAction({
    required this.broId,
    required super.message
  });
}

class SaveImagePopupAction extends MessagePopupAction {
  const SaveImagePopupAction({
    required super.message
  });
}

class ViewImagePopupAction extends MessagePopupAction {
  final int broId;
  const ViewImagePopupAction({
    required this.broId,
    required super.message
  });
}

class ReplyToMessagePopupAction extends MessagePopupAction {
  const ReplyToMessagePopupAction({
    required super.message
  });
}

class ShareMessagePopupAction extends MessagePopupAction {
  const ShareMessagePopupAction({
    required super.message
  });
}

class ForwardMessagePopupAction extends MessagePopupAction {
  const ForwardMessagePopupAction({
    required super.message
  });
}

class DeleteMessagePopupAction extends MessagePopupAction {
  const DeleteMessagePopupAction({
    required super.message
  });
}

class RemoveMessagePopupAction extends MessagePopupAction {
  const RemoveMessagePopupAction({
    required super.message
  });
}

class RemoveBroFromBroupPopupAction extends MessagePopupAction {
  final int broId;
  const RemoveBroFromBroupPopupAction({
    required this.broId,
    required super.message
  });
}

class MessageDetailPopup extends StatefulWidget {
  final Offset position;
  final void Function(MessagePopupAction) onAction;
  final List<Map<String, dynamic>> options;

  const MessageDetailPopup({
    required this.position,
    required this.onAction,
    required this.options,
    Key? key,
  }) : super(key: key);

  @override
  MessageDetailPopupState createState() => MessageDetailPopupState();
}

class MessageDetailPopupState extends State<MessageDetailPopup> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double getOptionWidth(String title, double widgetHeight) {
    final textSpan = TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();

    final textWidth = textPainter.size.width;

    double optionPadding = 20;
    // Add the padding and some final adjustments
    return textWidth + optionPadding + 4;
  }

  double getOptionHeight(String title, double widgetWidth) {
    final textSpan = TextSpan(
      text: title,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    );

    textPainter.layout(maxWidth: widgetWidth - 40);

    final textHeight = textPainter.size.height;

    double optionPadding = 20;
    // Add the padding and some final adjustments
    return textHeight + optionPadding + 4;
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double widgetWidth = screenWidth * 0.5;

    List<double> optionHeights = [];
    for (var option in widget.options) {
      optionHeights.add(getOptionHeight(option['text'], widgetWidth));
    }
    double widgetHeight = optionHeights.reduce((a, b) => a + b);

    double left = widget.position.dx - (widgetWidth / 2);
    double top = widget.position.dy - (widgetHeight / 2) - 100;

    // We move the widget down by 60 because that's the height of the emoji popup
    // and we want to show this popup below the emoji popup
    // It's divided by 2 because the center is in the middle of the widget
    // Which means we also go down by half the height of the message popup
    top += (widgetHeight / 2) + (60 / 2);

    if (left < 0) {
      left = 0;
    } else if (left + widgetWidth > screenWidth) {
      left = screenWidth - widgetWidth;
    }

    if (top < 60) {
      top = 60;
    } else if ((top + widgetHeight + 100) > screenHeight) {
      // Part of the message detail popup is off screen.
      // Move it all the way to be above the emoji popup
      // With some slight padding, similar to what you see when it's below the emoji popup.
      top -= widgetHeight + 60 + 10;
    }

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: widgetWidth,
            height: widgetHeight,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < widget.options.length; i++)
                  popupOption(
                      widget.options[i]["text"],
                      optionHeights[i], widget.options[i]["icon"],
                      widget.options[i]["action"]
                  ),
              ]
            ),
          ),
        ),
      ],
    );
  }

  Widget popupOption(String optionText, double optionHeight, IconData icon, MessagePopupAction popupAction) {
    return Container(
      height: optionHeight,
      color: Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onAction(popupAction);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
