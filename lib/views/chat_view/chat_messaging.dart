import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:brocast/objects/data_type.dart';
import 'package:brocast/views/chat_view/emoji_reactions_overview.dart';
import 'package:brocast/views/chat_view/message_attachment_popup.dart';
import 'package:brocast/views/chat_view/preview_page_chat/preview_page_chat.dart';
import 'package:brocast/views/chat_view/record_view_chat/record_view_chat.dart';
import 'package:brocast/views/forward_to/forward_to.dart';
import 'package:collection/collection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:brocast/objects/broup.dart';
import 'package:brocast/objects/message.dart';
import 'package:brocast/services/auth/v1_5/auth_service_social_v1_5.dart';
import 'package:brocast/utils/notification_controller.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/chat_view/messaging_change_notifier.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

import '../../../objects/bro.dart';
import '../../services/auth/v1_4/auth_service_social.dart';
import '../../objects/me.dart';
import '../../utils/life_cycle_service.dart';
import '../../utils/locator.dart';
import '../../utils/navigation_service.dart';
import '../../utils/storage.dart';
import '../camera_page/camera_page.dart';
import 'chat_details/chat_details.dart';
import 'location_view_chat/location_view_chat.dart';
import 'media_viewer/image_viewer.dart';
import 'media_viewer/location_viewer.dart';
import 'media_viewer/video_viewer.dart';
import 'message_detail_popup.dart';
import 'message_util.dart';
import 'models/message_tile.dart';
import 'package:brocast/constants/route_paths.dart' as routes;

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

  GlobalKey mediaKey = GlobalKey();

  Me? me;

  Map<int, Tuple2<GlobalKey, GlobalKey>> messageKeys = {};
  bool goingToReply = false;
  Map<int, bool> messageVisibility = {};
  int? goingToReplyMessageId;
  List<int> highlightedMessageIds = [];
  bool showBackToBottomButton = false;

  int emojiReactionMessageId = -1;
  bool showEmojiPopup = false;
  bool showEmojiPopupDeleted = false;
  bool showEmojiReactionOverview = false;
  List<EmojiOverviewData> emojiOverviewDataList = [];
  Offset emojiPopupPosition = Offset.zero;

  List<Map<String, dynamic>> messagePopupOptions = [];

  final NavigationService _navigationService = locator<NavigationService>();

  bool showMediaPopup = false;
  double mediaPopupYPos = 0;

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
  }

  void _onScroll() {
    // Check if the messageScrollController is 500 pixels from the top
    // Then set the showBackToBottomButton to true
    if (messageScrollController.position.pixels > 500) {
      if (!showBackToBottomButton) {
        setState(() {
          showBackToBottomButton = true;
        });
      }
    } else {
      if (showBackToBottomButton) {
        setState(() {
          showBackToBottomButton = false;
        });
      }
    }
    if (!busyRetrieving && !allMessagesDBRetrieved) {
      double distanceToTop =
          messageScrollController.position.maxScrollExtent -
              messageScrollController.position.pixels;
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

  _scrollToBottom() {
    messageScrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 800),
    );
  }

  highlightReplyMessage(int messageId) {
    setState(() {
      highlightedMessageIds.add(messageId);
    });
    // The animation takes 750 milliseconds.
    // After it's done we wait another 1250 milliseconds (the 2 seconds total)
    // Then we take 750 milliseconds to fade out the highlight.
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        highlightedMessageIds.remove(messageId);
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
      // Not really visible, but it should have context.
      Tuple2<GlobalKey, GlobalKey>? messageKeyPair = messageKeys[passedMessageId];
      // We assume that if it's in the `messageVisibility` List that it will have currentContext
      if (messageKeyPair != null) {
        GlobalKey messageKey = messageKeyPair.item1;
        if (messageKey.currentContext != null) {
          Scrollable.ensureVisible(
            messageKey.currentContext!,
            alignment: 0.8,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
          highlightReplyMessage(passedMessageId);
        }
      }
    } else {
      // Scroll to the message `messageScrollController.position.maxScrollExtent` is the top and 0 is the bottom.
      // get the index of the message with messageId == passedMessageId
      int index = widget.chat.messages.indexWhere((element) => element.messageId == passedMessageId);
      if (index != -1) {
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
      setDateTiles(widget.chat, (50 * amountViewed));
      checkRepliedMessages();
      checkIsAdmin();
      allMessagesDBRetrieved = value;
      checkMessageBroIds();
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

  void handleEmojiPopupAction(EmojiPopupAction action) {
    if (action is OutsideClicked) {
      highlightedMessageIds.remove(emojiReactionMessageId);
      showEmojiPopup = false;
      showEmojiPopupDeleted = false;
      emojiReactionMessageId = -1;
    } else if (action is ButtonPressed) {
      focusEmojiTextField.requestFocus();
      showEmojiPopup = false;
      showEmojiPopupDeleted = false;
      showEmojiKeyboard = true;
    } else if (action is EmojiSelected) {
      highlightedMessageIds.remove(emojiReactionMessageId);
      showEmojiPopup = false;
      showEmojiPopupDeleted = false;
      final String newEmoji = action.emoji;
      emojiReaction(newEmoji, emojiReactionMessageId);
      emojiReactionMessageId = -1;
    }
    setState(() {});
  }

  Future<bool> requestPermissions() async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      return await Gal.requestAccess();
    } else {
      return true;
    }
  }

  Future<String?> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (e) {
    }
    return directory?.path;
  }

  Future<PermissionStatus> _getStoragePermission() async {
    var permissionStatus = Platform.isIOS
        ? await Permission.storage.request()
        : await Permission.manageExternalStorage.request();
    if (permissionStatus.isDenied || permissionStatus.isRestricted) {
      // Here just ask for the permission for the first time
      permissionStatus = await Permission.storage.request();

      // I noticed that sometimes popup won't show after user press deny
      // so I do the check once again but now go straight to appSettings
      if (permissionStatus.isDenied) {
        await openAppSettings();
      }
    } else if (permissionStatus.isPermanentlyDenied) {
      // Here open app settings for user to manually enable permission in case
      // where permission was permanently denied
      await openAppSettings();
    }
    return permissionStatus;
  }

  Future<void> saveDataToGallery(Message message) async {
    try {
      bool access = await requestPermissions();
      if (!access) {
        showToastMessage("No access to gallery");
        return;
      }
      if (message.data != null) {
        String dataLoc = message.data!;
        final albumName = "Brocast";
        final directory = await getApplicationDocumentsDirectory();
        int randomNumber = Random().nextInt(100);
        String fileName = "brocast_${message.broupId}_${message.messageId}_$randomNumber";
        if (message.dataType == DataType.image.value || message.dataType == DataType.gif.value) {
          String imagePath = '${directory.path}/${fileName}.png';
          if (message.dataType == DataType.gif.value) {
            imagePath = '${directory.path}/${fileName}.gif';
          }
          final file = File(dataLoc);
          await file.copy(imagePath);
          await Gal.putImage(imagePath, album: albumName);
          showToastMessage("Image saved");
        } else if (message.dataType == DataType.video.value) {
          final videoPath = '${directory.path}/${fileName}.mp4';
          final file = File(dataLoc);
          await file.copy(videoPath);
          await Gal.putVideo(videoPath, album: albumName);
          showToastMessage("Video saved");
        } else if (message.dataType == DataType.audio.value) {
          PermissionStatus permissionStatus = await _getStoragePermission();
          if (permissionStatus == PermissionStatus.granted) {
            String? externalStoragePath = await _getDownloadPath();
            if (externalStoragePath == null) {
              showToastMessage("Storage permission denied");
              return;
            }
            final audioDir = Directory('$externalStoragePath/$albumName');
            if (!await audioDir.exists()) {
              await audioDir.create(recursive: true);
            }
            final audioPath = '${audioDir.path}/$fileName.m4a';
            final file = File(dataLoc);
            final newAudioFile = File(audioPath);
            await newAudioFile.writeAsBytes(file.readAsBytesSync());
            showToastMessage("Audio saved to storage");
          }
        } else if (message.dataType == DataType.other.value) {
          PermissionStatus permissionStatus = await _getStoragePermission();
          if (permissionStatus == PermissionStatus.granted) {
            String? externalStoragePath = await _getDownloadPath();
            if (externalStoragePath == null) {
              showToastMessage("Storage permission denied");
              return;
            }
            final docDir = Directory('$externalStoragePath/$albumName');
            if (!await docDir.exists()) {
              await docDir.create(recursive: true);
            }
            String docFileName = message.data!.split("/").last;
            final docPath = '${docDir.path}/$docFileName';
            final file = File(dataLoc);
            final newAudioFile = File(docPath);
            await newAudioFile.writeAsBytes(file.readAsBytesSync());
            showToastMessage("File saved to storage");
          }
        }
      }
    } catch (e) {
      showToastMessage("Failed to save image: $e");
    }
  }

  Uint8List getImage(Message message) {
    Uint8List? imageData = getMessageData(message.data!);
    if (imageData != null) {
      return imageData;
    }
    return Settings().notFoundImage;
  }

  Future<void> handleMessagePopupAction(MessagePopupAction action) async {

    showEmojiPopup = false;
    showEmojiPopupDeleted = false;
    emojiReactionMessageId = -1;

    if (action is MessageBroPopupAction) {
      Me? me = settings.getMe();
      if (me != null ) {
        for (Broup broup in me.broups) {
          if (broup.private) {
            for (int broId in broup.getBroIds()) {
              if (broId == action.broId) {
                navigateToChat(context, settings, broup);
              }
            }
          }
        }
      }
    } else if (action is AddNewBroPopupAction) {
      AuthServiceSocial().addNewBro(action.broId).then((response) {
        if (response.getResult()) {
          // The broup added, move to the home screen where it will be shown
          navigateToHome(context, settings);
        } else {
          showToastMessage(response.getMessage());
        }
      });
    } else if (action is MakeBroAdminPopupAction) {
      AuthServiceSocial().makeBroAdmin(widget.chat.broupId, action.broId).then((value) {
        if (value) {
          setState(() {
            widget.chat.addAdminId(action.broId);
            checkIsAdmin();
          });
        }
      });
    } else if (action is DismissBroAdminPopupAction) {
      AuthServiceSocial().dismissBroAdmin(widget.chat.broupId, action.broId).then((value) {
        if (value) {
          setState(() {
            widget.chat.removeAdminId(action.broId);
            checkIsAdmin();
          });
        }
      });
    } else if (action is SaveImagePopupAction) {
      saveDataToGallery(action.message);
    } else if (action is ViewImagePopupAction) {
      if (action.message.dataType == DataType.image.value || action.message.dataType == DataType.gif.value) {
        final file = File(action.message.data!);
        final tempDirectory = await getTemporaryDirectory();
        String newFilePath = '${tempDirectory.path}/previewImage_${action.message.messageId}.png';
        if (action.message.dataType == DataType.gif.value) {
          newFilePath = '${tempDirectory.path}/previewImage_${action.message.messageId}.gif';
        }
        File fileView = await file.copy(newFilePath);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ImageViewer(
                  key: UniqueKey(),
                  image: fileView,
                ),
          ),
        );
      } else if (action.message.dataType == DataType.video.value) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                VideoViewer(
                  key: UniqueKey(),
                  videoFilePath: action.message.data!,
                ),
          ),
        );
      } else if (action.message.dataType == DataType.location.value) {
        Me? me = Settings().getMe();
        if (me != null) {
          storage.fetchBro(action.broId).then((bro) {
            if (action.message.data != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      LocationViewer(
                        key: UniqueKey(),
                        locationData: action.message.data!,
                        liveLocation: false,
                        broupId: action.message.broupId,
                        bro: bro,
                        myMessage: me.getId() == action.message.senderId,
                        currentMessage: null,
                      ),
                ),
              ).then((_) {});
            }
          });
        }
      } else if (action.message.dataType == DataType.liveLocation.value) {
        Me? me = Settings().getMe();
        if (me != null) {
          if (action.message.data != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    LocationViewer(
                      key: UniqueKey(),
                      locationData: action.message.data!,
                      liveLocation: true,
                      broupId: action.message.broupId,
                      bro: null,
                      myMessage: me.getId() == action.message.senderId,
                      currentMessage: action.message,
                    ),
              ),
            ).then((_) {});
          }
        }
      }
    } else if (action is ReplyToMessagePopupAction) {
      repliedToMessage = widget.chat.messages.firstWhereOrNull((message) => message.messageId == action.message.messageId);
      if (repliedToMessage != null) {
        setState(() {
          repliedToInterface = true;
        });
      }
    } else if (action is RemoveBroFromBroupPopupAction) {
      AuthServiceSocial().removeBroToBroup(widget.chat.broupId, action.broId).then((value) {
        if (value) {
          setState(() {
            widget.chat.removeBro(action.broId);
            widget.chat.checkedRemainingBros = false;
            checkIsAdmin();
            retrieveData();
          });
        }
      });
    } else if (action is ShareMessagePopupAction) {
      Message messageShare = action.message;
      String emojiBody = messageShare.body;
      String? textMessage = messageShare.textMessage;
      String title = "Brocast message from broup " + widget.chat.broupName;
      if (widget.chat.private) {
        title = "Brocast message from bro " + widget.chat.broupName;
      }
      String shareText = emojiBody;
      if (textMessage != null) {
        shareText = emojiBody + "\n" + textMessage;
      }
      List<XFile>? filesShare = null;
      if (messageShare.dataType != null) {
        if (messageShare.dataType != DataType.location.value) {
          if (messageShare.dataType != DataType.liveLocation.value) {
            if (messageShare.dataType != DataType.liveLocationStop.value) {
              if (messageShare.data != null) {
                final file = File(messageShare.data!);
                final tempDirectory = await getTemporaryDirectory();
                String newFilePath = "";
                if (messageShare.dataType == DataType.image.value) {
                  newFilePath = '${tempDirectory.path}/previewImage_${messageShare.messageId}.png';
                } else if (messageShare.dataType == DataType.video.value) {
                  newFilePath = '${tempDirectory.path}/previewVideo_${messageShare.messageId}.mp4';
                } else if (messageShare.dataType == DataType.audio.value) {
                  newFilePath = '${tempDirectory.path}/previewAudio_${messageShare.messageId}.m4a';
                } else if (messageShare.dataType == DataType.gif.value) {
                  newFilePath = '${tempDirectory.path}/previewImage_${messageShare.messageId}.gif';
                } else if (messageShare.dataType == DataType.other.value) {
                  newFilePath = file.path;
                }
                if (newFilePath.isNotEmpty) {
                  final fileView = await file.copy(newFilePath);
                  filesShare = [XFile(fileView.path)];
                }
              }
            }
          }
        }
      }
      SharePlus.instance.share(
          ShareParams(
              title: title,
              text: shareText,
              files: filesShare
          )
      );
    } else if (action is ForwardMessagePopupAction) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ForwardTo(
            key: UniqueKey(),
            forwardMessage: action.message,
          )));
    } else if (action is DeleteMessagePopupAction) {
      showDialogDeleteMessage(context, action.message);
    } else if (action is RemoveMessagePopupAction) {
      Storage().deleteMessage(action.message.messageId, action.message.broupId).then((deleteMes) {
        widget.chat.messages.removeWhere((element) => element.messageId == action.message.messageId);
        setState(() {

        });
      });
    }

    setState(() {
      highlightedMessageIds.remove(action.message.messageId);
    });
  }

  deleteMessageForMe(Message deleteMessage) {
    Me? me = Settings().getMe();
    if (me == null) {
      showToastMessage("we had an issues getting your user information. Please log in again.");
      _navigationService.navigateTo(routes.SignInRoute);
      return;
    }
    deleteMessage.deleteMessageLocally(me.id);
    storage.updateMessage(deleteMessage).then((del) {
      setState(() {

      });
    });
  }

  deleteMessageForEveryone(Message deleteMessage) {
    Me? me = Settings().getMe();
    if (me == null) {
      showToastMessage("we had an issues getting your user information. Please log in again.");
      _navigationService.navigateTo(routes.SignInRoute);
      return;
    }
    AuthServiceSocialV15().deleteMessageEverybody(widget.chat.broupId, deleteMessage.messageId).then((value) {
      deleteMessage.deleteMessageLocally(me.id);
      storage.updateMessage(deleteMessage).then((del) {
        setState(() {

        });
      });
    });
  }

  deleteTheMessage(int deleteType, Message deleteMessage) {
    if (deleteType == 0) {
      deleteMessageForMe(deleteMessage);
    } else {
      deleteMessageForEveryone(deleteMessage);
    }
    Navigator.pop(context);
  }

  void showDialogDeleteMessage(BuildContext context, Message deleteMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            title: new Text("Delete message..."),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(2, (int index) {
                    return InkWell(
                      onTap: () {
                        setState(() => selectedRadio = index);
                      },
                      child: Row(children: [
                        Radio<int>(
                            value: index,
                            groupValue: selectedRadio,
                            onChanged: (int? value) {
                              if (value != null) {
                                setState(() => selectedRadio = value);
                              }
                            }),
                        index == 0
                            ? Container(child: Text("only for me"))
                            : Container(),
                        index == 1
                            ? Container(child: Text("for everybody"))
                            : Container(),
                      ]),
                    );
                  }),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete),
                    Text("Delete"),
                  ],
                ),
                onPressed: () {
                  deleteTheMessage(selectedRadio, deleteMessage);
                },
              ),
            ],
          );
        });
  }

  showEmojiReactions(Message message) {
    emojiOverviewDataList = [];
    message.emojiReactions.forEach((key, value) {
      String emoji = value;
      String broIdString = key;
      int broId = int.parse(broIdString);
      Bro? bro = getBro(broId);
      if (bro != null) {
        EmojiOverviewData emojiOverviewData = EmojiOverviewData(bro: bro, emoji: emoji);
        emojiOverviewDataList.add(emojiOverviewData);
      }
    });
    setState(() {
      showEmojiReactionOverview = true;
    });
  }

  emojiReaction(String emoji, emojiReactionMessageId) {
    String? currentEmojiReaction = getEmojiReaction(emojiReactionMessageId);
    bool isAdd = true;
    if (currentEmojiReaction != null && currentEmojiReaction == emoji) {
      isAdd = false;
    }
    AuthServiceSocialV15().messageEmojiReaction(widget.chat.broupId, emojiReactionMessageId, emoji, isAdd).then((value) {
      if (value) {
        Message? messageInBroup = widget.chat.messages.firstWhereOrNull((element) => element.messageId == emojiReactionMessageId);
        if (messageInBroup != null) {
          // We update the emoji reaction when the REST call is successful.
          // We will also update it via sockets, but we already know it worked so we set it here.
          if (me != null) {
            if (isAdd) {
              messageInBroup.addEmojiReaction(emoji, me!.getId());
            } else {
              messageInBroup.removeEmojiReaction(me!.getId());
            }
          }
        }
      }
    });
  }

  void onActionEmojiChanged(String emoji) {
    if (emojiReactionMessageId != -1) {
      highlightedMessageIds.remove(emojiReactionMessageId);
      emojiReaction(emoji, emojiReactionMessageId);
      emojiReactionMessageId = -1;
      if (showEmojiKeyboard) {
        showEmojiKeyboard = false;
      }
      setState(() {});
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
            checkMessageBroIds();
            checkRepliedMessages();
          }

          if (!settings.loggingIn) {
            // We set the last message we read to the lastMessageId. We check if it's more than what's stored.
            if (lifeCycleService.appOpen) {
              if (widget.chat.localLastMessageReadId < widget.chat.lastMessageId) {
                AuthServiceSocial()
                    .readMessages(widget.chat.broupId, widget.chat.lastMessageId)
                    .then((value) {
                  if (value) {
                    widget.chat.localLastMessageReadId = widget.chat.lastMessageId;
                    widget.chat.unreadMessages = 0;
                    storage.updateBroup(widget.chat);
                  }
                });
              }
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
    if (!widget.chat.checkedRemainingBros) {
      retrieveData();
      widget.chat.checkedRemainingBros = true;
    }
    checkMessageBroIds();
    checkRepliedMessages();
    checkIsAdmin();
    setState(() {});
  }

  socketListener() {
    // Do we set a flag on this?
    // We have received a new message, which might not have been picked up with the sockets
    if (widget.chat.newMessages) {
      retrieveData();
    }
    checkMessageBroIds();
    checkRepliedMessages();
    checkIsAdmin();
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
          if (value) {
            checkRepliedMessages();
          }
        });
      }
    });
  }

  retrieveRepliedMessages(List<int> retrieveMessagesIds) async {
    List<Message> newMessages = await storage.retrieveMessages(widget.chat.broupId, retrieveMessagesIds);
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
          messageId: 0,
          senderId: 0,
          body: "",
          textMessage: "",
          timestamp: DateTime.now().toUtc().toString(),
          data: null,
          info: false,
          broupId: widget.chat.broupId
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
    if (messageBroIds.contains(-1)) {
      messageBroIds.remove(-1);
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
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  messageLongPress(Message message, Offset pressPosition) {
    if (emojiReactionMessageId != -1) {
      highlightedMessageIds.remove(emojiReactionMessageId);
    }
    highlightedMessageIds.add(message.messageId);

    bool broAdded = getIsAdded(message.senderId);
    bool myMessage = message.senderId == settings.getMe()!.getId();
    bool broIsAdmin = getIsAdmin(message.senderId);
    bool broInBroup = widget.chat.broIds.contains(message.senderId);

    bool messageBroOption = broAdded && !myMessage && !widget.chat.private;
    bool addBroOption = !broAdded && !myMessage;
    bool makeBroAdmin = meAdmin && !broIsAdmin && !myMessage;
    bool dismissBroAdmin = meAdmin && broIsAdmin && !myMessage;
    bool saveImageOption = message.data != null && message.clicked;

    messagePopupOptions = [];
    if (!message.deleted) {
      if (messageBroOption && broInBroup) {
        messagePopupOptions.add({
          'text': 'Message Bro',
          'icon': Icons.message,
          'action': MessageBroPopupAction(message: message, broId: message.senderId)
        });
      }
      if (addBroOption && broInBroup) {
        messagePopupOptions.add({
          'text': 'Add New Bro',
          'icon': Icons.person_add,
          'action': AddNewBroPopupAction(message: message, broId: message.senderId)
        });
      }
      if (makeBroAdmin && broInBroup) {
        messagePopupOptions.add({
          'text': 'Make Bro Admin',
          'icon': Icons.admin_panel_settings,
          'action': MakeBroAdminPopupAction(message: message, broId: message.senderId)
        });
      }
      if (dismissBroAdmin && broInBroup) {
        messagePopupOptions.add({
          'text': 'Dismiss Bro Admin',
          'icon': Icons.admin_panel_settings_outlined,
          'action': DismissBroAdminPopupAction(message: message, broId: message.senderId)
        });
      }
      if (saveImageOption && message.dataType != null) {
        String type = DataType
            .getByValue(message.dataType!)
            .typeName;
        if (message.dataType != DataType.location.value ||
            message.dataType != DataType.liveLocation.value ||
            message.dataType != DataType.liveLocationStop.value) {
          messagePopupOptions.add({
            'text': 'Save $type',
            'icon': Icons.save_alt,
            'action': SaveImagePopupAction(message: message)
          });
        }
        messagePopupOptions.add({
          'text': 'View $type',
          'icon': Icons.remove_red_eye,
          'action': ViewImagePopupAction(message: message, broId: message.senderId)
        });
      }
      if (meAdmin && !myMessage && !widget.chat.private && broInBroup) {
        messagePopupOptions.add({
          'text': 'Remove bro from broup',
          'icon': Icons.person_remove,
          'action': RemoveBroFromBroupPopupAction(message: message, broId: message.senderId)
        });
      }
      messagePopupOptions.add({
        'text': 'Reply to Message',
        'icon': Icons.reply,
        'action': ReplyToMessagePopupAction(message: message)
      });
      if (message.dataType != DataType.location.value && message.dataType != DataType.liveLocation.value && message.dataType != DataType.liveLocationStop.value) {
        messagePopupOptions.add({'text': 'Share message', 'icon': Icons.share, 'action': ShareMessagePopupAction(message: message)});
        messagePopupOptions.add({'text': 'Forward message', 'icon': Icons.forward, 'action': ForwardMessagePopupAction(message: message)});
      }

      messagePopupOptions.add({'text': 'Delete message', 'icon': Icons.delete, 'action': DeleteMessagePopupAction(message: message)});
    } else {
      messagePopupOptions.add({'text': 'Remove message', 'icon': Icons.cleaning_services, 'action': RemoveMessagePopupAction(message: message)});
    }

    emojiReactionMessageId = message.messageId;
    setState(() {
      showEmojiPopup = true;
      showEmojiPopupDeleted = true;
      if (message.deleted) {
        showEmojiPopupDeleted = false;
      }
      emojiPopupPosition = pressPosition;
    });
  }

  String? getEmojiReaction(int messageId) {
    // Get the emoji that was placed by you on the message
    Message? message = widget.chat.messages.firstWhereOrNull((message) => message.messageId == messageId);
    if (message != null) {
      if (me != null) {
        if (message.emojiReactions.containsKey(me!.getId().toString())) {
          return message.emojiReactions[me!.getId().toString()];
        }
      }
    }
    return null;
  }

  messageHandling(int delta, int passedId) {
    if (delta == 0) {
      messageVisibility[passedId] = false;
    }
    // The passedId is usually the Bro Id, but for delta 3 and 6 it is the message Id.
    if (delta == 1) {
      // replied to message
      repliedToMessage = widget.chat.messages.firstWhereOrNull((message) => message.messageId == passedId);
      highlightedMessageIds.add(passedId);
      if (repliedToMessage != null) {
        setState(() {
          repliedToInterface = true;
        });
      }
    } else if (delta == 2) {
      // go to Reply message
      // passedId is the messageId
      // get the lowest messageId from widget.chat.messages excluding the 0 messageId
      int lowestMessageId = widget.chat.messages.where((element) => element.messageId != 0).map((e) => e.messageId).reduce(min);
      if (passedId < lowestMessageId) {
        // Message not currently loaded, but it should be on the storage
        fetchExtraMessagesLocal(passedId);
      } else {
        // Check if "passedId" is a in the `messageVisibility` Map
        checkMessageIsVisible(passedId);
      }
    } else if (delta == 3) {
      // Clicked the emoji reactions on a message
      // passedId is the messageId
      Message? clickedMessage = widget.chat.messages.firstWhereOrNull((message) => message.messageId == passedId);
      if (clickedMessage != null) {
        showEmojiReactions(clickedMessage);
      }
    } else if (delta == 4) {
      Message? clickedMessage = widget.chat.messages.firstWhereOrNull((message) => message.messageId == passedId);
      if (clickedMessage != null) {
        saveDataToGallery(clickedMessage);
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

  sendMessage() async {
    if (formKey.currentState!.validate()) {
      int meId = -1;
      int newMessageId = widget.chat.lastMessageId + 1;
      Me? me = settings.getMe();
      if (me == null) {
        showToastMessage("we had an issues getting your user information. Please log in again.");
        // This needs to be filled if the user is logged in, if it's not we send the bro back to the login
        _navigationService.navigateTo(routes.SignInRoute);
        return;
      } else {
        meId = me.getId();
      }

      int? repliedToMessageId;
      if (repliedToMessage != null) {
        repliedToMessageId = repliedToMessage!.messageId;
      }

      String message = broMessageController.text;
      String textMessage = appendTextMessageController.text;
      Message mes = Message(
          messageId: newMessageId,
          senderId: meId,
          body: message,
          textMessage: textMessage,
          timestamp: DateTime.now().toUtc().toString(),
          data: null,
          info: false,
          broupId: widget.chat.broupId,
          repliedMessage: repliedToMessage,
          repliedTo: repliedToMessageId,
      );
      mes.isRead = 2;
      widget.chat.messages.insert(0, mes);

      if (repliedToMessage != null) {
        setState(() {
          highlightedMessageIds.remove(repliedToMessage!.messageId);
          repliedToMessage = null;
          repliedToInterface = false;
        });
      }
      setState(() {
        widget.chat.sendingMessage = true;
      });
      // Send the message. The data is always null here because it's only send via the preview page.
      AuthServiceSocialV15().sendMessage(widget.chat.getBroupId(), message, textMessage, null, null, repliedToMessageId).then((messageId) async {
        isLoadingMessages = false;
        // We predict what the messageId will be but in the end it is determined by the server.
        // If it's different we want to update it.
        if (messageId != null) {
          mes.isRead = 0;
          if (mes.messageId != messageId) {
            mes.messageId = messageId;
            await storage.addMessage(mes);
          }
          // message send
        } else {
          // The message was not sent, we remove it from the list and the database
          storage.deleteMessage(mes.messageId, widget.chat.broupId);
          showToastMessage("there was an issue sending the message");
          for (int i = 0; i < 5; i++) {
            // There might be some messages retrieved in between this period.
            // While this is unlikely, check for the correct message to remove.
            if (widget.chat.messages[i] == mes) {
              widget.chat.messages.removeAt(i);
              break;
            }
          }
        }
        setState(() {
          widget.chat.sendingMessage = false;
        });
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
    FilePickerResult? picked = await FilePicker.platform.pickFiles(
      withData: false,
      type: FileType.any,
      allowMultiple: false,
    );

    if (picked != null) {
      PlatformFile platformFile = picked.files.first;
      String? extension = platformFile.extension;
      File mediaFile = File(platformFile.path!);
      if (extension == null) {
        showToastMessage("can't detect extension");
        return;
      }
      int dataType = 0;
      final imageExtensions = ["jpg", "jpeg", "png", "webp", "heic", "heif", "bmp"];
      final videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv", "flv", "wmv", "3gp", "webm"];
      final audioExtensions = ["mp3", "aac", "m4a"];
      if (imageExtensions.contains(extension.toLowerCase())) {
        dataType = DataType.image.value;
      } else if (videoExtensions.contains(extension.toLowerCase())) {
        dataType = DataType.video.value;
      } else if (audioExtensions.contains(extension.toLowerCase())) {
        dataType = DataType.audio.value;
      } else if (extension == "gif") {
        dataType = DataType.gif.value;
      } else {
        dataType = DataType.other.value;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PreviewPageChat(
                key: UniqueKey(),
                fromGallery: true,
                chat: widget.chat,
                mediaFile: mediaFile,
                dataType: dataType,
              ),
        ),
      );
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
              Message message = widget.chat.messages[index];
              messageVisibility[message.messageId] = true;
              GlobalKey? messageKey;
              GlobalKey? messageAnimationKey;
              if (!message.info) {
                Tuple2<GlobalKey, GlobalKey> messageKeyPair = messageKeys.putIfAbsent(message.messageId, () => Tuple2(GlobalKey(), GlobalKey()));
                messageKey = messageKeyPair.item1;
                messageAnimationKey = messageKeyPair.item2;
              }
              bool isHighlighted = highlightedMessageIds.contains(message.messageId);
              MessageTile messageTile = MessageTile(
                  key: messageKey == null ? GlobalKey() : messageKey,
                  private: widget.chat.private,
                  message: message,
                  bro: getBro(message.senderId),
                  broAdded: getIsAdded(message.senderId),
                  broAdmin: getIsAdmin(message.senderId),
                  myMessage: message.senderId == settings.getMe()!.getId(),
                  userAdmin: meAdmin,
                  repliedMessage: message.repliedMessage,
                  repliedBro: getBroReply(message.repliedMessage),
                  animationKey: messageAnimationKey == null ? GlobalKey() : messageAnimationKey,
                  messageHandling: messageHandling,
                  messageLongPress: messageLongPress,
              );
              return Container(
                padding: EdgeInsets.only(top: 4),
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 750),
                    curve: Curves.linear,
                    color: isHighlighted ? widget.chat.getColor() : Colors.transparent,
                    child: messageTile
                ),
              );
            })
        : Container();
  }

  _showPopupMedia() async {
    RenderBox? box = mediaKey.currentContext!.findRenderObject() as RenderBox?;

    Offset mediaPopupPosition = box!.localToGlobal(Offset.zero);

    mediaPopupYPos = mediaPopupPosition.dy;

    setState(() {
      showMediaPopup = true;
    });
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
    if (emojiReactionMessageId != -1) {
      highlightedMessageIds.remove(emojiReactionMessageId);
      emojiReactionMessageId = -1;
    }
    if (showMediaPopup) {
      setState(() {
        showMediaPopup = false;
      });
    } else if (showEmojiPopup) {
      setState(() {
        showEmojiPopup = false;
        showEmojiPopupDeleted = false;
      });
    } else if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      // Set all the "clicked" messages back to false
      widget.chat.messages.where((message) => message.clicked).forEach((message) => message.clicked = false);
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
                  Expanded(
                    child: Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.transparent,
                        child: Text(widget.chat.getBroupNameOrAlias(),
                          style: TextStyle(
                              color: getTextColor(widget.chat.getColor()),
                              fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                    ),
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
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
                highlightedMessageIds.remove(repliedToMessage!.messageId);
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

  void handleMediaPopupAction(MessageAttachmentPopupAction action) {
    if (action is AttachmentOutsideClicked) {
      showMediaPopup = false;
    } else if (action is AttachmentGalleryClicked) {
      imageLoaded();
      showMediaPopup = false;
    } else if (action is AttachmentCameraClicked) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => CameraPage(
            key: UniqueKey(),
            chat: widget.chat,
            changeAvatar: false,
          )
        ),
      );
      showMediaPopup = false;
    } else if (action is AttachmentMicClicked) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => RecordViewChat(
            key: UniqueKey(),
            chat: widget.chat,
          )
        ),
      );
    } else if (action is AttachmentLocationClicked) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(
          builder: (context) => LocationViewChat(
            key: UniqueKey(),
            chat: widget.chat,
          )
      ),
      );
    }

    setState(() {});
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
        body: Stack(
          children: [
            Container(
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
                            showBackToBottomButton ? Positioned(
                              bottom: 16.0,
                              right: 16.0,
                              child: IconButton(
                                icon: CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  radius: 16.0,
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 16.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                onPressed: _scrollToBottom,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                              ),
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
                                  _showPopupMedia();
                                },
                                child: Container(
                                    key: mediaKey,
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
                  appendingMessage ? Container(
                    child: Container(
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
                    ),
                  ) : Container(),
                  !showEmojiKeyboard ? SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 5,
                  ) : Container(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: EmojiKeyboard(
                      emojiController: emojiReactionMessageId == -1 ? broMessageController : null,
                      onEmojiChanged: onActionEmojiChanged,
                      emojiKeyboardHeight: 350,
                      showEmojiKeyboard: showEmojiKeyboard,
                      darkMode: settings.getEmojiKeyboardDarkMode(),
                      emojiKeyboardAnimationDuration: const Duration(milliseconds: 200),
                    ),
                  ),
                ],
              ),
            ),
            EmojiKeyboardPopup(
              position: emojiPopupPosition,
              showEmojiPopup: showEmojiPopup,
              onAction: handleEmojiPopupAction,
              darkMode: settings.getEmojiKeyboardDarkMode(),
              popupWidth: showEmojiPopupDeleted ? 350 : 0,
              highlightedEmoji: emojiReactionMessageId == -1
                  ? null
                  : getEmojiReaction(emojiReactionMessageId),
              emojiPopupAnimationDuration: const Duration(
                  milliseconds: 200),
            ),
            if (showEmojiPopup)
              MessageDetailPopup(
                position: emojiPopupPosition,
                onAction: handleMessagePopupAction,
                options: messagePopupOptions,
              ),
            if (showEmojiReactionOverview)
              EmojiReactionsOverview(
                emojiOverviewDataList: emojiOverviewDataList,
                onOutsideTap: () {
                  setState(() {
                    showEmojiReactionOverview = false;
                  });
                },
              ),
              MessageAttachmentPopup(
                onAction: handleMediaPopupAction,
                showMediaPopup: showMediaPopup,
                yPosition: mediaPopupYPos,
              )
          ],
        ),
      ),
    );
  }
}
