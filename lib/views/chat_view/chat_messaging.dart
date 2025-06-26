import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';

import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/auth/v1_5/auth_service_social_v1_5.dart';
import 'package:brocast/utils/notification_controller.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:camera/camera.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../objects/bro.dart';
import '../../services/auth/v1_4/auth_service_social.dart';
import '../../objects/me.dart';
import '../../utils/life_cycle_service.dart';
import '../../utils/popup_menu_override.dart';
import '../../utils/storage.dart';
import '../camera_page/camera_page.dart';
import '../preview_page_chat/preview_page_chat.dart';
import 'chat_details/chat_details.dart';
import 'message_util.dart';
import 'models/bro_message_tile.dart';
import 'models/broup_message_tile.dart';
import 'models/message_tile.dart';

class ChatMessaging extends StatefulWidget {
  final Broup chat;

  ChatMessaging({required Key key, required this.chat}) : super(key: key);

  @override
  _ChatMessagingState createState() => _ChatMessagingState();
}

class _ChatMessagingState extends State<ChatMessaging> with SingleTickerProviderStateMixin {
  bool isLoadingBros = false;
  bool isLoadingMessages = false;
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();
  MessagingChangeNotifier messagingChangeNotifier = MessagingChangeNotifier();
  late LifeCycleService lifeCycleService;

  bool showEmojiKeyboard = false;

  FocusNode focusAppendText = FocusNode();
  FocusNode focusEmojiTextField = FocusNode();
  bool appendingMessage = false;
  bool repliedToInterface = false;
  Message? repliedToMessage;

  TextEditingController broMessageController = new TextEditingController();
  TextEditingController appendTextMessageController =
      new TextEditingController();
  final formKey = GlobalKey<FormState>();

  late Storage storage;

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

  Me? me;

  bool goingToReply = false;
  Map<int, bool> messageVisibility = {};
  int? goingToReplyMessageId;
  int? highlightedMessageId;
  AnimationController? _animationController;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    storage = Storage();
    socketServices.addListener(socketListener);
    messagingChangeNotifier.addListener(messagingListener);

    me = Settings().getMe();

    lifeCycleService = LifeCycleService();
    lifeCycleService.addListener(lifeCycleChangeListener);

    messageScrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      retrieveData();
      // used for the popup.
      navigator = Navigator.of(context, rootNavigator: false);
      barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
      capturedThemes = InheritedTheme.capture(from: context, to: navigator!.context);

      if (messagingChangeNotifier.broupId != widget.chat.broupId) {
        // If the chat seems to be different we close the previous chat and set the new one to open.
        messagingChangeNotifier.isOpen = true;
        AuthServiceSocial().chatOpen(messagingChangeNotifier.getBroupId(), false);
        AuthServiceSocial().chatOpen(widget.chat.broupId, true);
        messagingChangeNotifier.setBroupId(widget.chat.broupId);
      } else if (!messagingChangeNotifier.isOpen) {
        messagingChangeNotifier.isOpen = true;
        AuthServiceSocial().chatOpen(widget.chat.broupId, true);
        messagingChangeNotifier.setBroupId(widget.chat.broupId);
      }
      // We moved to a chat so we need to reset the notification controller
      NotificationController().navigateChat = false;
      NotificationController().navigateChatId = -1;
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(begin: Colors.teal, end: null).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.linear,
        reverseCurve: Curves.linear,
      ))
      ..addListener(() {
        setState(() {});
      });
  }

  void _onScroll() {
    if (!busyRetrieving && !allMessagesDBRetrieved) {
      double distanceToTop =
          messageScrollController.position.maxScrollExtent -
              messageScrollController.position.pixels;
      print("distanceToTop: $distanceToTop");
      if (distanceToTop < 1000) {
        fetchExtraMessagesLocal(null);
      }
    }

    // When going to a reply that's not in the listview at the moment
    // We will just scroll to the top until it will be in the listview
    // Once we detect it we can ensure it's visible in the screen.
    if (!goingToReply) {
      return;
    }
    if (goingToReplyMessageId != null) {
      checkMessageIsVisible(goingToReplyMessageId!);
    }
  }

  highlightReplyMessage() {
    print("highlightReplyMessage $goingToReplyMessageId   $goingToReply");
    setState(() {
      highlightedMessageId = goingToReplyMessageId;
    });
    _animationController?.forward().then((_) {
      print("animation forward");
      _animationController?.reverse().then((_) {
        print("animation reverse");
        setState(() {
          highlightedMessageId = null;
        });
      });
    });
    goingToReplyMessageId = null;
    goingToReply = false;
  }

  checkMessageIsVisible(int passedMessageId) {
    if (messageVisibility.containsKey(passedMessageId)
        && messageVisibility[passedMessageId] != null
        && messageVisibility[passedMessageId]!) {
      // These might already have these values, but they might not so we set them again.
      goingToReplyMessageId = passedMessageId;
      goingToReply = true;
      print("Message visible!");
      // Not really visible, but it should have context.
      GlobalKey? messageKey = messageKeys[passedMessageId];
      // We assume that if it's in the `messageVisibility` List that it will have currentContext
      if (messageKey != null) {
        print("context available? ${messageKey.currentContext != null}");
        if (messageKey.currentContext != null) {
          print("ensuring visibility! :)");
          Scrollable.ensureVisible(
            messageKey.currentContext!,
            alignment: 0.8,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          highlightReplyMessage();
        } else {
          print("context nullll!?!?!?");
          SystemNavigator.pop();
        }
      } else {
        print("Message key not found!?!?!?!");
        SystemNavigator.pop();
      }
    } else {
      print("not currently visible!");
      // Scroll to the message `messageScrollController.position.maxScrollExtent` is the top and 0 is the bottom.
      // get the index of the message with messageId == passedMessageId
      int index = widget.chat.messages.indexWhere((element) => element.messageId == passedMessageId);
      if (index != -1) {
        print("scrolling to the top!!!!");
        // index 0 will be the newest message
        // index (widget.chat.messages.length - 1) will be the oldest message
        // Scroll towards the top until the message is visible and then stop.
        messageScrollController.animateTo(
          messageScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 800),
          curve: Curves.linear,
        );
        goingToReplyMessageId = passedMessageId;
        goingToReply = true;
      }
    }
  }

  fetchExtraMessagesLocal(int? untilMessageId) {
    busyRetrieving = true;
    amountViewed += 1;
    fetchExtraMessages(amountViewed, widget.chat, storage).then((value) {
      print("fetched extra messages");
      setDateTiles(widget.chat, (50 * amountViewed));
      checkRepliedMessages();
      checkIsAdmin();
      allMessagesDBRetrieved = value;
      setState(() {
        busyRetrieving = false;
      });
      if (untilMessageId != null) {
        int lowestMessageId = widget.chat.messages.where((element) => element.messageId != 0).map((e) => e.messageId).reduce(min);
        if (untilMessageId < lowestMessageId) {
          fetchExtraMessagesLocal(untilMessageId);
        } else {
          checkMessageIsVisible(untilMessageId);
        }
      }
    });
  }

  lifeCycleChangeListener() {
    // Is called when the app is resumed
    retrieveData();
    if (!messagingChangeNotifier.isOpen) {
      messagingChangeNotifier.broupId = widget.chat.broupId;
      AuthServiceSocial().chatOpen(widget.chat.broupId, true);
    }
  }

  checkIsAdmin() {
    for (Bro bro in widget.chat.getBroupBros()) {
      broAdminStatus[bro.id.toString()] = false;
      broAddedStatus[bro.id.toString()] = false;
      broMapping[bro.id.toString()] = bro;
    }
    for (Bro broRemaining in widget.chat.messageBroRemaining) {
      // These bros are not in the broupBros list, but they have messages send in the broup
      // So we need to display them correctly.
      broAddedStatus[broRemaining.id.toString()] = false;
      broMapping[broRemaining.id.toString()] = broRemaining;
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
    getBroupDataBroup(widget.chat, storage, me).then((value) {
      getMessages(0, widget.chat, storage).then((value) {
        allMessagesDBRetrieved = value;
        setState(() {
          if (widget.chat.messages.isNotEmpty) {
            if (!widget.chat.dateTilesAdded) {
              widget.chat.dateTilesAdded = true;
              setDateTiles(widget.chat, 0);
              widget.chat.messages.sort((b, a) => a.getTimeStamp().compareTo(b.getTimeStamp()));
            }
            if (!widget.chat.checkedRemainingBros) {
              widget.chat.checkedRemainingBros = true;
              checkMessageBroIds();
            }
            checkRepliedMessages();
          }

          if (!settings.loggingIn) {
            // We set the last message we read to the lastMessageId. We check if it's more than what's stored.
            if (widget.chat.lastMessageReadId < widget.chat.lastMessageId) {
              AuthServiceSocial().readMessages(widget.chat.broupId, widget.chat.lastMessageId).then((value) {
                if (value) {
                  widget.chat.lastMessageReadId = widget.chat.lastMessageId;
                  widget.chat.updateLastReadMessages(widget.chat.lastMessageReadId, storage);
                  widget.chat.unreadMessages = 0;
                  storage.updateBroup(widget.chat);
                }
              });
            }
          }

          widget.chat.unreadMessages = 0;
          storage.updateBroup(widget.chat);
          isLoadingMessages = false;
        });
      });
      getBros(widget.chat, storage, settings.getMe()!).then((value) {
        checkIsAdmin();
        widget.chat.unreadMessages = 0;
        storage.updateBroup(widget.chat);
        setState(() {
          isLoadingBros = false;
        });
      });
    });
  }

  messagingListener() {
    print("messagingListener");
    checkRepliedMessages();
    checkIsAdmin();
    setState(() {});
  }

  socketListener() {
    print("socketListener");
    // Do we set a flag on this?
    checkRepliedMessages();
    checkIsAdmin();
    // We have received a new message, which might not have been picked up with the sockets
    if (widget.chat.newMessages) {
      retrieveData();
    }
    setState(() {});
  }

  retrieveRepliedBros(List<int> repliedMessageBrosNotYetLoaded) {
    // TODO: test this. Create a broup add a message and leave the broup.
    //  Other bros will add many many messages and finally reply to the first message
    //  If you are a bro that has not read the chat yet the bro will not be loaded
    //  In this case it should trigger a server call.
    storage.fetchBros(repliedMessageBrosNotYetLoaded).then((brosDb) {
      for (Bro broDb in brosDb) {
        repliedMessageBrosNotYetLoaded.remove(broDb.getId());
        widget.chat.messageBroRemaining.add(broDb);
      }
      if (repliedMessageBrosNotYetLoaded.isNotEmpty) {
        AuthServiceSocial().broDetails([], repliedMessageBrosNotYetLoaded, widget.chat.broupId).then((value) {
          // If we have retrieved the bros we call the reply function again
          checkRepliedMessages();
        });
      }
    });
  }

  retrieveRepliedMessages(List<int> retrieveMessagesIds) async {
    List<Message> newMessages = await storage.retrieveMessages(retrieveMessagesIds);
    List<int> repliedMessageBrosNotYetLoaded = [];
    for (Message message in widget.chat.messages) {
      if (message.repliedTo != null) {
        if (message.repliedMessage == null) {
          Message? retrievedRepliedMessage = newMessages.firstWhereOrNull((element) => element.messageId == message.repliedTo);
          if (retrievedRepliedMessage != null) {
            retrieveMessagesIds.remove(retrievedRepliedMessage.messageId);
            message.repliedMessage = retrievedRepliedMessage;
            Bro? replyMessageBro = getBro(retrievedRepliedMessage.senderId);
            if (replyMessageBro == null) {
              repliedMessageBrosNotYetLoaded.add(retrievedRepliedMessage.senderId);
            } else {
              widget.chat.messageBroRemaining.add(replyMessageBro);
            }
          }
        }
      }
    }
    if (repliedMessageBrosNotYetLoaded.isNotEmpty) {
      retrieveRepliedBros(repliedMessageBrosNotYetLoaded);
    }
    if (retrieveMessagesIds.isNotEmpty) {
      // If you join a broup later on? You won't have the message and you can't get the message.
      // We will add a empty message to indicate that the message is not available.
      Message emptyMessage = Message(
          0,
          0,
          "",
          "",
          DateTime.now().toIso8601String(),
          null,
          true,
          widget.chat.broupId
      );
      emptyMessage.repliedTo = -1;
      for (Message message in widget.chat.messages) {
        if (message.repliedTo != null) {
          if (message.repliedMessage == null) {
            message.repliedMessage = emptyMessage;
          }
        }
      }
    }
    setState(() {
      checkIsAdmin();
    });
  }

  checkRepliedMessages() {
    // Here we want to see if messages are replies to other messages.
    // In this case we want the message to be loaded
    // and have a reference stored on the message object
    List<int> repliedMessageIdNotYetLoaded = [];
    List<int> repliedMessageBrosNotYetLoaded = [];
    for (Message message in widget.chat.messages) {
      if (message.repliedTo != null) {
        if (message.repliedMessage == null) {
          // The replied message has not been loaded yet.
          // We need to load it.
          Message? repliedMessage = widget.chat.messages
              .firstWhereOrNull((element) => element.messageId == message.repliedTo);
          if (repliedMessage != null) {
            message.repliedMessage = repliedMessage;
            Bro? replyMessageBro = getBro(repliedMessage.senderId);
            if (replyMessageBro == null) {
              repliedMessageBrosNotYetLoaded.add(repliedMessage.senderId);
            } else {
              widget.chat.messageBroRemaining.add(replyMessageBro);
            }
          } else {
            // keep track of all the replied messages that are not yet loaded,
            // so we can load them separately
            repliedMessageIdNotYetLoaded.add(message.repliedTo!);
          }
        }
      }
    }
    if (repliedMessageBrosNotYetLoaded.isNotEmpty) {
      retrieveRepliedBros(repliedMessageBrosNotYetLoaded);
    }
    if (repliedMessageIdNotYetLoaded.isNotEmpty) {
      retrieveRepliedMessages(repliedMessageIdNotYetLoaded);
    }
  }

  // It's possible that a bro send a message and then left.
  // In this case we still want to correctly display the message.
  // So we retrieve it from the db to present the correct data.
  // If the data is not present yet, we will retrieve it.
  checkMessageBroIds() {
    List<int> messageBroIds = widget.chat.messages
        .where((message) => !message.info)
        .map((message) => message.senderId)
        .toSet()
        .toList();
    // These are information messages, so we don't need to check them
    if (messageBroIds.contains(0)) {
      messageBroIds.remove(0);
    }
    if (messageBroIds.contains(settings.getMe()!.getId())) {
      messageBroIds.remove(settings.getMe()!.getId());
    }
    for (Bro chatBro in widget.chat.broupBros) {
      if (messageBroIds.contains(chatBro.getId())) {
        messageBroIds.remove(chatBro.getId());
      }
    }
    if (messageBroIds.isNotEmpty) {
      for (Bro bro in widget.chat.broupBros) {
        if (messageBroIds.contains(bro.getId())) {
          messageBroIds.remove(bro.getId());
        }
      }
      if (messageBroIds.isNotEmpty) {
        storage.fetchBros(messageBroIds).then((brosDb) {
          for (Bro broDb in brosDb) {
            if (!widget.chat.messageBroRemaining.any((element) =>
            element.getId() == broDb.getId())) {
              widget.chat.messageBroRemaining.add(broDb);
            }
            messageBroIds.remove(broDb.getId());
          }
          if (messageBroIds.isNotEmpty) {
            // If there are still id's remaining we have never retrieved them.
            // So retrieve them now because we want to show the correct message data.
            AuthServiceSocial().broDetails([], messageBroIds, widget.chat.broupId).then((value) {
              // If we have retrieved the bros we call this function again
              checkMessageBroIds();
            });
          }
          checkIsAdmin();
          setState(() {});
        });
      }
    }
  }

  broHandling(int delta, int passedId) {
    // We also use the broHandling to determine if the message is disposed
    // Which means it's not visible anymore.
    if (delta == 0) {
      messageVisibility[passedId] = false;
    }
    // The passedId is usually the Bro Id, but for delta 3 and 6 it is the message Id.
    if (delta == 1) {
      // Message the bro
      Me? me = settings.getMe();
      if (me != null ) {
        for (Broup broup in me.broups) {
          if (broup.private) {
            for (int broId in broup.getBroIds()) {
              if (broId == passedId) {
                navigateToChat(context, settings, broup);
              }
            }
          }
        }
      }
    } else if (delta == 2) {
      // Add the bro
      AuthServiceSocial().addNewBro(passedId).then((response) {
        if (response.getResult()) {
          // The broup added, move to the home screen where it will be shown
          navigateToHome(context, settings);
        } else {
          showToastMessage(response.getMessage());
        }
      });
    } else if (delta == 3) {
      // replied to message
      repliedToMessage = widget.chat.messages.firstWhereOrNull((message) => message.messageId == passedId);
      if (repliedToMessage != null) {
        setState(() {
          repliedToInterface = true;
        });
      }
    } else if (delta == 4) {
      AuthServiceSocial().makeBroAdmin(widget.chat.broupId, passedId).then((value) {
        if (value) {
          setState(() {
            widget.chat.addAdminId(passedId);
            checkIsAdmin();
          });
        }
      });
    } else if (delta == 5) {
      AuthServiceSocial().dismissBroAdmin(widget.chat.broupId, passedId).then((value) {
        if (value) {
          setState(() {
            widget.chat.removeAdminId(passedId);
            checkIsAdmin();
          });
        }
      });
    } else if (delta == 6) {
      // go to Reply message
      // passedId is the messageId
      // get the lowest messageId from widget.chat.messages excluding the 0 messageId
      int lowestMessageId = widget.chat.messages.where((element) => element.messageId != 0).map((e) => e.messageId).reduce(min);
      print("lowestMessageId: $lowestMessageId");
      if (passedId < lowestMessageId) {
        // Message not currently loaded, but it should be on the storage
        fetchExtraMessagesLocal(passedId);
      } else {
        // Check if "passedId" is a in the `messageVisibility` Map
        checkMessageIsVisible(passedId);
      }
    }
  }

  @override
  void dispose() {
    focusAppendText.dispose();
    focusEmojiTextField.dispose();
    socketServices.removeListener(socketListener);
    messagingChangeNotifier.removeListener(messagingListener);
    lifeCycleService.removeListener(lifeCycleChangeListener);
    broMessageController.dispose();
    appendTextMessageController.dispose();
    _animationController?.dispose();
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

  sendMessage() {
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
        widget.chat.messages.insert(0, mes);
      });
      // Send the message. The data is always null here because it's only send via the preview page.
      int? repliedToMessageId;
      if (repliedToMessage != null) {
        repliedToMessageId = repliedToMessage!.messageId;
        setState(() {
          repliedToMessage = null;
          repliedToInterface = false;
        });
      }
      AuthServiceSocialV15().sendMessage(widget.chat.getBroupId(), message, textMessage, null, repliedToMessageId).then((value) {
        isLoadingMessages = false;
        if (value) {
          setState(() {
            mes.isRead = 0;
          });
          // message send
        } else {
          // The message was not sent, we remove it from the list
          showToastMessage("there was an issue sending the message");
          setState(() {
            // TODO: There might be some messages retrieved in between this period. Check for the correct message to remove.
            widget.chat.messages.removeAt(0);
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
        ).then((_) { });
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
    ).then((_) { });
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
        color: Colors.transparent,
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

  Map<int, GlobalKey> messageKeys = {};
  Widget messageList() {
    return widget.chat.messages.isNotEmpty
        ? ListView.builder(
            itemCount: widget.chat.messages.length,
            shrinkWrap: true,
            reverse: true,
            controller: messageScrollController,
            itemBuilder: (context, index) {
              Message message = widget.chat.messages[index];
              messageVisibility[message.messageId] = true;
              GlobalKey messageKey = messageKeys.putIfAbsent(message.messageId, () => GlobalKey());
              bool isHighlighted = message.messageId == highlightedMessageId;
              MessageTile messageTile = MessageTile(
                  key: messageKey,
                  private: widget.chat.private,
                  message: message,
                  bro: getBro(message.senderId),
                  broAdded: getIsAdded(message.senderId),
                  broAdmin: getIsAdmin(message.senderId),
                  myMessage: message.senderId == settings.getMe()!.getId(),
                  userAdmin: meAdmin,
                  repliedMessage: message.repliedMessage,
                  repliedBro: getBroReply(message.repliedMessage),
                  broHandling: broHandling);
              return AnimatedContainer(
                  duration: Duration(milliseconds: 750),
                  curve: Curves.linear,
                  color: isHighlighted ? Colors.teal : Colors.transparent,
                  child: messageTile
              );
            })
        : Container();
  }

  Bro? getBroReply(Message? repliedMessage) {
    if (repliedMessage != null) {
      return getBro(repliedMessage.senderId);
    }
    return null;
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
    closeChat();
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

  Widget repliedToMessageInterface() {
    if (repliedToMessage == null) {
      return Container();
    }

    // Fetch the sender's name from the broMapping map
    Bro? sender = getBro(repliedToMessage!.senderId);
    String senderName = sender != null ? sender.getFullName() : "Unknown";

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 10, right: 10),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 5),
      color: Colors.black.withAlpha(64),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.reply,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    senderName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      repliedToMessage!.body,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (repliedToMessage!.textMessage != null && repliedToMessage!.textMessage != "")
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '-',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        repliedToMessage!.textMessage!,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 4,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  repliedToMessage = null;
                  repliedToInterface = false;
                });
              },
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
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
              repliedToInterface
                  ? repliedToMessageInterface()
                  : Container(),
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
                              sendMessage();
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
                height: MediaQuery.of(context).padding.bottom + 5,
              ) : Container(),
              Align(
                alignment: Alignment.bottomCenter,
                child: EmojiKeyboard(
                  emojiController: broMessageController,
                  emojiKeyboardHeight: 350,
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