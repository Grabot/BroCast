import 'dart:async';
import 'dart:typed_data';
import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/utils/notification_controller.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:camera/camera.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../objects/bro.dart';
import '../../../services/auth/auth_service_social.dart';
import '../../utils/popup_menu_override.dart';
import '../../utils/storage.dart';
import '../../objects/me.dart';
import '../camera_page/camera_page.dart';
import '../preview_page_chat/preview_page_chat.dart';
import 'chat_details/chat_details.dart';
import 'message_util.dart';
import 'models/bro_message_tile.dart';
import 'models/broup_message_tile.dart';

class ChatMessaging extends StatefulWidget {
  final Broup chat;

  ChatMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _ChatMessagingState createState() => _ChatMessagingState();
}

class _ChatMessagingState extends State<ChatMessaging> {
  bool isLoadingBros = false;
  bool isLoadingMessages = false;
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();
  MessagingChangeNotifier messagingChangeNotifier = MessagingChangeNotifier();

  bool showEmojiKeyboard = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();

  late Storage storage;
  late NotificationController notificationController;

  int amountViewed = 0;
  bool allMessagesDBRetrieved = false;
  bool busyRetrieving = false;

  var messageScrollController = ScrollController();

  bool meAdmin = false;
  Map<String, bool> broAdminStatus = {};
  Map<String, bool> broAddedStatus = {};
  Map<String, Bro> broMapping = {};

  NavigatorState? navigator;
  String barrierLabel = "";
  CapturedThemes? capturedThemes;

  // The key for the photo Icon
  GlobalKey photoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    print("init chat");
    storage = Storage();
    socketServices.addListener(socketListener);
    messagingChangeNotifier.addListener(socketListener);

    notificationController = NotificationController();
    notificationController.addListener(notificationListener);

    messageScrollController.addListener(() {
      if (!busyRetrieving && !allMessagesDBRetrieved) {
        double distanceToTop =
            messageScrollController.position.maxScrollExtent -
                messageScrollController.position.pixels;
        print("distance to top: $distanceToTop");
        if (distanceToTop < 1000) {
          busyRetrieving = true;
          amountViewed += 1;
          print("fetching extra messages!");
          fetchExtraMessages(amountViewed, widget.chat, storage).then((value) {
            allMessagesDBRetrieved = value;
            busyRetrieving = false;
          });
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      retrieveData();
      navigator = Navigator.of(context, rootNavigator: false);
      barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
      capturedThemes =
          InheritedTheme.capture(from: context, to: navigator!.context);
    });
  }

  notificationListener() {
    print("chat notification listener ${notificationController.navigateChat}");
    if (notificationController.navigateChat) {
      // TODO: Fix navigation via notification
      // notificationController.navigateChat = false;
      // int chatId = notificationController.navigateChatId;
      // storage.fetchBroup(chatId).then((broup) {
      //   if (broup != null) {
      //     notificationController.navigateChat = false;
      //     notificationController.navigateChatId = -1;
      //
      //     print("navigating to chat???");
      //     if (broup.broupId != widget.chat.broupId) {
      //       print("changing chat object");
      //       widget.chat = broup;
      //       retrieveData();
      //       messagingChangeNotifier.setBroupId(widget.chat.getBroupId());
      //       setState(() {});
      //     }
      //   }
      // });
    }
  }

  checkIsAdmin() {
    for (Bro bro in widget.chat.getBroupBros()) {
      broAdminStatus[bro.id.toString()] = false;
      broAddedStatus[bro.id.toString()] = false;
      broMapping[bro.id.toString()] = bro;
    }
    meAdmin = false;
    for (int adminId in widget.chat.getAdminIds()) {
      if (adminId == settings.getMe()!.getId()) {
        meAdmin = true;
      }
      for (Bro bro in widget.chat.getBroupBros()) {
        if (bro.id == adminId) {
          broAdminStatus[bro.id.toString()] = true;
        }
      }
    }
    for (Broup broup in settings.getMe()!.broups) {
      if (broup.private) {
        for (int broId in broup.getBroIds()) {
          if (broId != settings.getMe()!.getId()) {
            if (broAddedStatus.containsKey(broId.toString())) {
              broAddedStatus[broId.toString()] = true;
            }
          }
        }
      }
    }
  }

  retrieveData() {
    setState(() {
      isLoadingBros = true;
      isLoadingMessages = true;
    });
    getBroupUpdate(widget.chat, storage).then((value) {
      getMessages(0, widget.chat, storage).then((value) {
        allMessagesDBRetrieved = value;
        setState(() {
          if (widget.chat.messages.length != 0) {
            setDateTiles(widget.chat);
            if (widget.chat.messages[0].messageId <= 0) {
              widget.chat.lastMessageId = widget.chat.messages[1].messageId;
            } else {
              widget.chat.lastMessageId = widget.chat.messages[0].messageId;
            }
          }
          isLoadingMessages = false;
        });
      });
      print("chat id: ${widget.chat.broupId}");
      Me? me = settings.getMe();
      print("me: $me");
      getBros(widget.chat, storage, settings.getMe()!).then((value) {
        checkIsAdmin();
        setState(() {
          isLoadingBros = false;
        });
      });
    });
  }

  socketListener() {
    checkIsAdmin();
    setState(() {});
  }

  broHandling(int delta, int addBroId) {
    if (delta == 1) {
      // Message the bro
      Me? me = settings.getMe();
      if (me != null ) {
        for (Broup broup in me.broups) {
          if (broup.private) {
            for (int broId in broup.getBroIds()) {
              if (broId == addBroId) {
                // TODO: Fix via regular navigation?
                // // We are already in the chat window.
                // // We attempt to transfer the correct data here.
                // widget.chat = broup;
                // retrieveData();
                // messagingChangeNotifier.setBroupId(widget.chat.getBroupId());
                // setState(() {});
              }
            }
          }
        }
      }
    } else if (delta == 2) {
      // Add the bro
      AuthServiceSocial().addNewBro(addBroId).then((value) {
        if (value) {
          print("we have added a new bro :)");
          // The broup added, move to the home screen where it will be shown
          navigateToHome(context, settings);
        } else {
          showToastMessage("Bro contact already in Bro list!");
        }
      });
    } else if (delta == 4) {
      AuthServiceSocial().makeBroAdmin(widget.chat.broupId, addBroId).then((value) {
        if (value) {
          setState(() {
            widget.chat.addAdminId(addBroId);
            checkIsAdmin();
          });
        }
      });
    } else if (delta == 5) {
      AuthServiceSocial().dismissBroAdmin(widget.chat.broupId, addBroId).then((value) {
        if (value) {
          setState(() {
            widget.chat.removeAdminId(addBroId);
            checkIsAdmin();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    // If you are on the page and you leave than you have read the messages.
    widget.chat.unreadMessages = 0;
    notificationController.removeListener(notificationListener);
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    socketServices.removeListener(socketListener);
    messagingChangeNotifier.removeListener(socketListener);
    broMessageController.dispose();
    appendTextMessageController.dispose();
    super.dispose();
  }

  appendTextMessage() {
    if (!appendingMessage) {
      focusAppendText.requestFocus();
      if (broMessageController.text == "") {
        broMessageController.text = "✉️";
      }
      setState(() {
        showEmojiKeyboard = false;
        appendingMessage = true;
      });
    } else {
      focusEmojiTextField.requestFocus();
      appendTextMessageController.text = "";
      if (broMessageController.text == "✉️") {
        broMessageController.text = "";
      }
      setState(() {
        showEmojiKeyboard = true;
        appendingMessage = false;
      });
    }
  }

  sendMessage(String? messageData) {
    if (formKey.currentState!.validate()) {
      String message = broMessageController.text;
      String textMessage = appendTextMessageController.text;
      Message mes = new Message(
        widget.chat.lastMessageId + 1,
        settings.getMe()!.getId(),
        message,
        textMessage,
        DateTime.now().toUtc().toString(),
        null,
        false,
        widget.chat.getBroupId(),
      );
      mes.isRead = 2;
      setState(() {
        if (messageData == null) {
          // only do this for regular messages, because they will be deleted again if we receive the message. Which is not done for messages with data.
          widget.chat.messages.insert(0, mes);
        }
      });
      AuthServiceSocial().sendMessage(widget.chat.getBroupId(), message, textMessage, messageData).then((value) {
        if (value) {
          mes.isRead = 0;
          // message send
        } else {
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          setState(() {
            if (messageData == null) {
              widget.chat.messages.removeAt(0);
            }
          });
        }
      });
      broMessageController.clear();
      appendTextMessageController.clear();

      if (appendingMessage) {
        focusEmojiTextField.requestFocus();
        setState(() {
          showEmojiKeyboard = true;
          appendingMessage = false;
        });
      }
    }
  }

  imageLoaded() async {
    FilePickerResult? picked = await FilePicker.platform.pickFiles(withData: true);

    if (picked != null) {
      String? extension = picked.files.first.extension;
      if (extension != "png" && extension != "jpg" && extension != "jpeg") {
        showToastMessage("Can only upload images with extension .png, .jpg or .jpeg");
      } else {
        Uint8List photoData = picked.files.first.bytes!;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
              PreviewPageChat(
                key: UniqueKey(),
                chat: widget.chat,
                image: photoData,
              ),
            ),
        ).then((imageData) {
          if (imageData != null) {
            // imageData should be a list of 3 strings, the image, bro message and possible text message
            String imageString = imageData[0];
            String broMessage = imageData[1];
            String appendTextMessage = imageData[2];

            broMessageController.text = broMessage;
            appendTextMessageController.text = appendTextMessage;
            sendMessage(imageString);
          } else {
            showToastMessage("image not send");
          }
        });
      }
    }
  }

  List<Icon> popupItems = [
    Icon(
      Icons.camera_alt,
      color: Colors.blue,
    ),
    Icon(
      Icons.image,
      color: Colors.blue,
    )
  ];

  sendMessageData(Uint8List imageData) {
    print("sending message with data");
    // clear the text field because it is taken from the preview page.
    broMessageController.text = "";
    appendTextMessageController.text = "";
    // Returned from the camera with the image
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PreviewPageChat(
              key: UniqueKey(),
              chat: widget.chat,
              image: imageData,
            ),
      ),
    ).then((imageData) {
      if (imageData != null) {
        // imageData should be a list of 3 strings, the image, bro message and possible text message
        String imageString = imageData[0];
        String broMessage = imageData[1];
        String appendTextMessage = imageData[2];

        broMessageController.text = broMessage;
        appendTextMessageController.text = appendTextMessage;
        sendMessage(imageString);
      } else {
        showToastMessage("image not send");
      }
    });
  }

  addNewComponent(int popupIndex) {
    Navigator.of(context).pop();
    if (popupIndex == 0) {
      availableCameras().then((value) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CameraPage(
            key: UniqueKey(),
            chat: widget.chat,
            isMe: false,
            cameras: value,
          )
        ),
        ).then((imageData) async {
          if (imageData != null) {
            sendMessageData(imageData);
          }
        });
      });
    } else {
      imageLoaded();
    }
  }

  _showPopupPhoto(GlobalKey keyKey) async {
    RenderBox? box = keyKey.currentContext!.findRenderObject() as RenderBox?;

    Offset position = box!.localToGlobal(Offset.zero);

    double xPos = MediaQuery.of(context).size.width / 2;
    double yPos = position.dy - 20;

    // We want space for 2 buttons, gallery and camera
    double widthPopup = 140;
    double heightPopup = 70;

    RelativeRect popupPosition = RelativeRect.fromLTRB(
        xPos - widthPopup / 2,
        yPos - heightPopup,
        xPos + widthPopup / 2,
        yPos - heightPopup
    );

    if (navigator != null && capturedThemes != null) {
      showMenuOverride(
        position: popupPosition,
        widthPopup: widthPopup,
        heightPopup: heightPopup,
        color: Colors.black,
        navigator: navigator!,
        barrierLabel: barrierLabel,
        capturedThemes: capturedThemes!,
        items: [
          ComponentDetailPopup(
              key: UniqueKey(),
              components: popupItems,
              addNewComponent: addNewComponent
          )
        ],
      ).then((value) {
        return;
      });
    }
  }

  Widget messageList() {
    return widget.chat.messages.isNotEmpty
        ? ListView.builder(
            itemCount: widget.chat.messages.length,
            shrinkWrap: true,
            reverse: true,
            controller: messageScrollController,
            itemBuilder: (context, index) {
              if (widget.chat.private) {
                return BroMessageTile(
                    key: UniqueKey(),
                    message: widget.chat.messages[index],
                    myMessage: widget.chat.messages[index].senderId == settings.getMe()!.getId());
              } else {
                return BroupMessageTile(
                    key: UniqueKey(),
                    message: widget.chat.messages[index],
                    bro: getBro(widget.chat.messages[index].senderId),
                    senderName: getSender(widget.chat.messages[index].senderId),
                    senderId: widget.chat.messages[index].senderId,
                    broAdded: getIsAdded(widget.chat.messages[index].senderId),
                    broAdmin: getIsAdmin(widget.chat.messages[index].senderId),
                    myMessage: widget.chat.messages[index].senderId ==
                        settings.getMe()!.getId(),
                    userAdmin: meAdmin,
                    broHandling: broHandling);
              }
            })
        : Container();
  }

  Bro? getBro(int senderId) {
    return broMapping[senderId.toString()];
  }

  bool getIsAdded(int senderId) {
    if (broAddedStatus[senderId.toString()] != null) {
      return broAddedStatus[senderId.toString()]!;
    }
    return false;
  }

  bool getIsAdmin(int senderId) {
    if (broAdminStatus[senderId.toString()] != null) {
      return broAdminStatus[senderId.toString()]!;
    }
    return false;
  }

  String getSender(int senderId) {
    String broName = "";
    for (Bro bro in widget.chat.broupBros) {
      if (bro.id == senderId) {
        return bro.getFullName();
      }
    }
    return broName;
  }

  void onTapEmojiTextField() {
    if (!showEmojiKeyboard) {
      Timer(Duration(milliseconds: 100), () {
        setState(() {
          showEmojiKeyboard = true;
        });
      });
    }
  }

  void onTapAppendTextField() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    }
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      navigateToHome(context, settings);
    }
  }

  goToChatDetails() {
    messagingChangeNotifier.setBroupId(-1);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatDetails(key: UniqueKey(), chat: widget.chat)));
  }

  PreferredSize appBarChat() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Ink(
        color: widget.chat.getColor(),
        child: InkWell(
          onTap: () {
            goToChatDetails();
          },
          child: AppBar(
              leading: IconButton(
                  icon:
                      Icon(Icons.arrow_back, color: getTextColor(widget.chat.getColor())),
                  onPressed: () {
                    backButtonFunctionality();
                  }),
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    child: avatarBox(50, 50, widget.chat.getAvatar()),
                  ),
                  SizedBox(width: 5),
                  Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    child: Text(widget.chat.getBroupNameOrAlias(),
                        style: TextStyle(
                            color: getTextColor(widget.chat.getColor()),
                            fontSize: 20)
                    )
                  )
                ],
              ),
              actions: [
                PopupMenuButton<int>(
                    icon: Icon(Icons.more_vert, color: getTextColor(widget.chat.getColor())),
                    onSelected: (item) => onSelectChat(context, item),
                    itemBuilder: (context) => [
                          PopupMenuItem<int>(value: 0, child: Text("Profile")),
                          PopupMenuItem<int>(value: 1, child: Text("Settings")),
                          PopupMenuItem<int>(
                              value: 2, child: Text("Broup details")),
                          PopupMenuItem<int>(value: 3, child: Text("Home"))
                        ])
              ]),
        ),
      ),
    );
  }

  void onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        navigateToProfile(context, settings);
        break;
      case 1:
        navigateToSettings(context, settings);
        break;
      case 2:
        goToChatDetails();
        break;
      case 3:
        navigateToHome(context, settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        appBar: appBarChat(),
        body: Container(
          child: Column(
            children: [
              Expanded(
                  child: Stack(
                      children: [
                        messageList(),
                        isLoadingBros || isLoadingMessages
                            ? Center(
                            child: Container(
                                child: CircularProgressIndicator()
                            )
                        ) : Container(),
                      ]
                  )
              ),
              Container(
                child: Container(
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
                          GestureDetector(
                            onTap: () {
                              appendTextMessage();
                            },
                            child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    color: appendingMessage
                                        ? Colors.green
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(35)),
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.text_snippet,
                                    color: appendingMessage
                                        ? Colors.white
                                        : Color(0xFF616161))),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 15),
                              child: Form(
                                key: formKey,
                                child: TextFormField(
                                  focusNode: focusEmojiTextField,
                                  validator: (val) {
                                    if (val == null ||
                                        val.isEmpty ||
                                        val.trimRight().isEmpty) {
                                      return "Can't send an empty message";
                                    }
                                    if (widget.chat.isRemoved()) {
                                      return "You're no longer a participant in this Broup";
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    onTapEmojiTextField();
                                  },
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  controller: broMessageController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      hintText: "Emoji message...",
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                      border: InputBorder.none),
                                  readOnly: true,
                                  showCursor: true,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              _showPopupPhoto(photoKey);
                            },
                            child: Container(
                                key: photoKey,
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(35)),
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                    Icons.attach_file,
                                    color: Color(0xFF616161)
                                )
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              sendMessage(null);
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
                ),
              ),
              Container(
                  child: appendingMessage
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6),
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
                                        onTap: () {
                                          onTapAppendTextField();
                                        },
                                        focusNode: focusAppendText,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        controller: appendTextMessageController,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                            hintText: "Append text message...",
                                            hintStyle: TextStyle(
                                                color: Colors.white54),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()),
              !showEmojiKeyboard ? SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ) : Container(),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                  emojiController: broMessageController,
                  emojiKeyboardHeight: 400,
                  showEmojiKeyboard: showEmojiKeyboard,
                  darkMode: settings.getEmojiKeyboardDarkMode(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

