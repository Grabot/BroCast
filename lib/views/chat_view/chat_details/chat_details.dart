import 'package:brocast/objects/broup.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import '../../../objects/bro.dart';
import '../../../objects/me.dart';
import '../../../services/auth/auth_service_settings.dart';
import '../../../services/auth/auth_service_social.dart';
import '../../../utils/notification_controller.dart';
import '../../../utils/storage.dart';
import '../../bro_home/bro_home.dart';
import '../../bro_profile/bro_profile.dart';
import '../../bro_settings/bro_settings.dart';
import '../chat_messaging.dart';
import '../message_util.dart';
import '../messaging_change_notifier.dart';
import 'add_participant/broup_add_participant.dart';
import 'models/bro_tile_details.dart';

class ChatDetails extends StatefulWidget {
  final Broup chat;

  ChatDetails({required Key key, required this.chat}) : super(key: key);

  @override
  _ChatDetailsState createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  Settings settings = Settings();
  SocketServices socketServices = SocketServices();

  TextEditingController chatDescriptionController = new TextEditingController();
  TextEditingController chatAliasController = new TextEditingController();

  bool changeDescription = false;
  bool changeAlias = false;
  bool changeColour = false;

  late int amountInGroup;

  late CircleColorPickerController circleColorPickerController;

  late Color currentColor;
  Color? previousColor;

  FocusNode focusNodeDescription = new FocusNode();
  FocusNode focusNodeAlias = new FocusNode();

  String previousDescription = "";
  String previousAlias = "";

  late Broup chat;

  late Storage storage;

  double iconSize = 30;

  bool meAdmin = false;
  Map<String, bool> broAdminStatus = {};
  // Not every bro in a broup will be in your personal bro list
  // In that case different options will be available
  Map<String, bool> broAddedStatus = {};

  late NotificationController notificationController;

  @override
  void initState() {
    super.initState();
    chat = widget.chat;
    storage = Storage();
    amountInGroup = chat.getBroIds().length;
    socketServices.checkConnection();
    socketServices.addListener(socketListener);

    notificationController = NotificationController();
    notificationController.addListener(notificationListener);

    chatDescriptionController.text = chat.broupDescription;
    chatAliasController.text = chat.alias;

    checkAdmin();

    circleColorPickerController = CircleColorPickerController(
      initialColor: chat.getColor(),
    );
    currentColor = chat.getColor();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

  }

  notificationListener() {
    if (mounted) {
      if (notificationController.navigateChat) {
        notificationController.navigateChat = false;
        int chatId = notificationController.navigateChatId;
        storage.fetchBroup(chatId).then((broup) {
          if (broup != null) {
            notificationController.navigateChat = false;
            notificationController.navigateChatId = -1;
            navigateToChat(context, settings, broup);
          }
        });
      }
    }
  }

  checkAdmin() {
    meAdmin = false;
    for (Bro bro in chat.getBroupBros()) {
      broAdminStatus[bro.id.toString()] = false;
      broAddedStatus[bro.id.toString()] = false;
    }
    for (int adminId in chat.getAdminIds()) {
      if (adminId == settings.getMe()!.getId()) {
        meAdmin = true;
      }
      for (Bro bro in chat.getBroupBros()) {
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

  participantChange() {
    checkAdmin();
    amountInGroup = chat.getBroupBros().length;
    setState(() {});
  }

  socketListener() {
    if (chat.getBroupBros().length < chat.broIds.length) {
      // There is probably a new bro in the broup.
      // It would have retrieved the bros in the previous screen, so there was
      // a new bro id added via sockets.
      // We will find which id and retrieve it.
      // First we will check if it's in the DB
      List<int> broIdsToRetrieve = [...chat.getBroIds()];
      for (Bro bro in chat.getBroupBros()) {
        broIdsToRetrieve.remove(bro.id);
      }
      print("ids missing from broup: $broIdsToRetrieve");
      storage.fetchBros(broIdsToRetrieve).then((value) {
        if (value.isNotEmpty) {
          for (Bro bro in value) {
            chat.addBro(bro);
            broIdsToRetrieve.remove(bro.id);
          }
        }
        print("ids missing from broup after db check: $broIdsToRetrieve");
        if (broIdsToRetrieve.isEmpty) {
          participantChange();
        }
        AuthServiceSocial().retrieveBros(broIdsToRetrieve).then((value) {
          if (value.isNotEmpty) {
            for (Bro bro in value) {
              chat.addBro(bro);
              storage.addBro(bro);
            }
          }
          participantChange();
        });
      });
    } else {
      participantChange();
    }
  }

  broHandling(int delta, int broId) {
    if (delta == 1) {
      AuthServiceSocial().addNewBro(broId).then((value) {
        if (value) {
          print("we have added a new bro :)");
          // The broup added, move to the home screen where it will be shown
          navigateToHome(context, settings);
        } else {
          showToastMessage("Bro contact already in Bro list!");
        }
      });
    } else if (delta == 2) {
      print("making bro admin");
      AuthServiceSocial().makeBroAdmin(chat.broupId, broId).then((value) {
        if (value) {
          setState(() {
            chat.addAdminId(broId);
            checkAdmin();
          });
        }
      });
    } else if (delta == 3) {
      print('dismissing bro from admin');
      AuthServiceSocial().dismissBroAdmin(chat.broupId, broId).then((value) {
        if (value) {
          setState(() {
            chat.removeAdminId(broId);
            checkAdmin();
          });
        }
      });
    } else if (delta == 4) {
      print('Remove bro from chat.');
      AuthServiceSocial().removeBroToBroup(chat.broupId, broId).then((value) {
        if (value) {
          setState(() {
            chat.removeBro(broId);
            amountInGroup = chat.getBroupBros().length;
            print("bro has been removed :'(");
          });
        }
      });
    }
  }

  broupWasMuted(var data) {
    // if (data.containsKey("result")) {
    //   bool result = data["result"];
    //   if (result) {
    //     setState(() {
    //       chat.setMuted(data["mute"]);
    //     });
    //   }
    // }
  }

  broupMutingFailed() {
    showToastMessage("Broup muting failed at this time.");
  }

  void backButtonFunctionality() {
    if (changeDescription) {
      setState(() {
        chatDescriptionController.text = previousDescription;
        changeDescription = false;
        FocusScope.of(context).unfocus();
      });
    } else if (changeAlias) {
      setState(() {
        chatAliasController.text = previousAlias;
        changeAlias = false;
        FocusScope.of(context).unfocus();
      });
    } else {
      navigateToChat(context, settings, chat);
    }
  }

  @override
  void dispose() {
    socketServices.removeListener(socketListener);
    chatDescriptionController.dispose();
    chatAliasController.dispose();
    focusNodeDescription.dispose();
    focusNodeAlias.dispose();
    super.dispose();
  }

  PreferredSize appBarChatDetails() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: getTextColor(chat.getColor())),
              onPressed: () {
                backButtonFunctionality();
              }),
          backgroundColor: chat.getColor(),
          title: Text(chat.getBroupNameOrAlias(),
              style: TextStyle(
                  color: getTextColor(chat.getColor()), fontSize: 20)),
          actions: [
            PopupMenuButton<int>(
                onSelected: (item) => onSelectChat(context, item),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 0, child: Text("Profile")),
                      PopupMenuItem<int>(value: 1, child: Text("Settings")),
                      PopupMenuItem<int>(
                          value: 2, child: Text("Back to broup")),
                      PopupMenuItem<int>(value: 3, child: Text("Home"))
                    ])
          ]),
    );
  }

  onSelectChat(BuildContext context, int item) {
    switch (item) {
      case 0:
        navigateToProfile(context, settings);
        break;
      case 1:
        navigateToSettings(context, settings);
        break;
      case 2:
        navigateToChat(context, settings, chat);
        break;
      case 3:
        navigateToHome(context, settings);
        break;
    }
  }

  void onTapDescriptionField() {
    previousDescription = chatDescriptionController.text;
    focusNodeDescription.requestFocus();
    setState(() {
      changeDescription = true;
    });
  }

  void onTapAliasField() {
    previousAlias = chatAliasController.text;
    focusNodeAlias.requestFocus();
    setState(() {
      changeAlias = true;
    });
  }

  updateDescription() {
    if (previousDescription != chatDescriptionController.text) {
      String newBroupDescription = chatDescriptionController.text;
      AuthServiceSettings().changeDescriptionBroup(chat.getBroupId(), newBroupDescription).then((val) {
        if (val) {
          // The details are updated via sockets.
          setState(() {});
        } else {
          showToastMessage("something went wrong with changing the description");
          currentColor = previousColor!;
        }
        setState(() {
          changeColour = false;
        });
      });
    }
    setState(() {
      FocusScope.of(context).unfocus();
      changeDescription = false;
    });
  }

  updateAlias() {
    if (previousAlias != chatAliasController.text) {
      String newBroupAlias = chatAliasController.text;
      AuthServiceSettings().changeAliasBroup(chat.getBroupId(), newBroupAlias).then((val) {
        if (val) {
          // Since this is only visible for the bro
          // we don't get an update via sockets
          // So we update it once we have received a response from the server
          chat.alias = newBroupAlias;
          storage.updateBroup(chat);
          setState(() {});
        } else {
          showToastMessage("something went wrong with changing the alias");
          currentColor = previousColor!;
        }
        setState(() {
          changeColour = false;
        });
      });
    }
    setState(() {
      FocusScope.of(context).unfocus();
      changeAlias = false;
    });
  }

  updateColour() {
    previousColor = currentColor;
    setState(() {
      changeColour = true;
    });
  }

  String toHex(Color test) {
    final hexR = (test.r * 255).round().toRadixString(16).padLeft(2, '0');
    final hexG = (test.g * 255).round().toRadixString(16).padLeft(2, '0');
    final hexB = (test.b * 255).round().toRadixString(16).padLeft(2, '0');

    return '$hexR$hexG$hexB';
  }

  saveColour() {
    if (currentColor != chat.getColor()) {
      String newBroupColour = toHex(currentColor);
      AuthServiceSettings().changeColourBroup(chat.getBroupId(), newBroupColour).then((val) {
        if (val) {
          // The details are updated via sockets.
        } else {
          showToastMessage("something went wrong with changing the colour");
          currentColor = previousColor!;
        }
        setState(() {
          changeColour = false;
        });
      });
    }
  }

  onColorChange(Color colour) {
    currentColor = colour;
  }

  Widget brosInBroupList() {
    return chat.getBroupBros().isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: chat.getBroupBros().length,
            itemBuilder: (context, index) {
              return BroTileDetails(
                  key: UniqueKey(),
                  bro: chat.getBroupBros()[index],
                  broAdmin: broAdminStatus[chat.getBroupBros()[index].id.toString()]!,
                  broAdded: broAddedStatus[chat.getBroupBros()[index].id.toString()]!,
                  broupId: chat.broupId,
                  userAdmin: meAdmin,
                  broHandling: broHandling
              );
            })
        : Container();
  }

  addParticipant() {
    settings.doneRoutes.add(routes.ChatAddParticipantsRoute);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BroupAddParticipant(key: UniqueKey(), chat: chat))).then((value) {
                  print("got back from adding a participant");
                  // Check if we added a new participant.
                  getBros(chat, Storage(), settings.getMe()!).then((value) {
                    setState(() {
                      socketListener();
                    });
                  });
    });
  }

  Widget broCastLogo() {
    return Container(
        alignment: Alignment.center,
        child:
        Image.asset("assets/images/brocast_transparent.png"));
  }

  Widget broupNameHeader() {
    if (chat.alias.isNotEmpty) {
      return Column(children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              "${chat.alias}",
              style: TextStyle(
                  color: Colors.white, fontSize: 25),
            )),
        SizedBox(height: 10),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              "${chat.getBroupName()}",
              style: TextStyle(
                  color: Colors.white, fontSize: 16),
            ))
      ]);
    } else {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            "${chat.getBroupName()}",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ));
    }
  }

  Widget broHasLeft() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            "You're no longer a participant in this Broup",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          )),
        Container(
          child: TextButton(
              style: ButtonStyle(
                foregroundColor:
                WidgetStateProperty.all<Color>(
                    Colors.red),
              ),
              onPressed: () {
                showDialogDelete(
                    context, chat.getBroupNameOrAlias());
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 20),
                    Text(
                      'Delete Broup',
                      style: simpleTextStyle(),
                    ),
                  ])),
        )
    ]
    );
  }

  Widget chatAliasWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 100,
          child: TextFormField(
            focusNode: focusNodeAlias,
            onTap: () {
              onTapAliasField();
            },
            controller: chatAliasController,
            style: simpleTextStyle(),
            textAlign: TextAlign.center,
            decoration: textFieldInputDecoration(
                "No chat alias yet"),
          ),
        ),
        SizedBox(width: 5),
        changeAlias
            ? Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.check,
                  color: Colors.white),
              onPressed: () {
                updateAlias();
              }),
        )
            : Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.edit,
                  color: Colors.white),
              onPressed: () {
                onTapAliasField();
              }),
        ),
      ],
    );
  }

  Widget chatColourWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: InkWell(
            onTap: () {
              updateColour();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Color:",
                  style: simpleTextStyle(),
                ),
                SizedBox(width: 20),
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: chat.getColor(),
                      borderRadius:
                      BorderRadius.circular(40)),
                ),
              ],
            ),
          ),
        ),
        changeColour ? Column(
            children: [
              CircleColorPicker(
                controller: circleColorPickerController,
                textStyle: simpleTextStyle(),
                onChanged: (colour) {
                  setState(() => onColorChange(colour));
                },
              ),
              IconButton(
                  iconSize: iconSize,
                  icon: Icon(Icons.check,
                      color: Colors.green),
                  onPressed: () {
                    saveColour();
                  }),
            ]) : Container(),
      ]
    );
  }

  Widget broupDescriptionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // 20 padding on both sides, 5 sizedbox and 18 for button
          width:
          MediaQuery.of(context).size.width - 100,
          child: TextFormField(
            focusNode: focusNodeDescription,
            maxLines: null,
            onTap: () {
              onTapDescriptionField();
            },
            controller: chatDescriptionController,
            style: simpleTextStyle(),
            textAlign: TextAlign.center,
            decoration: textFieldInputDecoration(
                "No chat description yet"),
          ),
        ),
        SizedBox(width: 5),
        changeDescription
            ? Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.check,
                  color: Colors.white),
              onPressed: () {
                updateDescription();
              }),
        )
            : Container(
          width: iconSize,
          height: iconSize,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.edit,
                  color: Colors.white),
              onPressed: () {
                onTapDescriptionField();
              }),
        ),
      ],
    );
  }

  Widget chatDetailsBro() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          child: Text(
              "Bro",
              style: simpleTextStyle()),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: brosInBroupList(),
        ),
      ],
    );
  }

  Widget chatDetailsParticipants() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          child: Text(
              "" +
                  amountInGroup.toString() +
                  " Participants",
              style: simpleTextStyle()),
        ),
        SizedBox(height: 10),
        meAdmin ? InkWell(
          onTap: () {
            addParticipant();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 24, vertical: 6),
            child: Row(children: [
              Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(
                          Radius.circular(40))),
                  child: IconButton(
                    onPressed: () {
                      addParticipant();
                    },
                    icon: Icon(Icons.person_add,
                        color: Colors.white),
                  )),
              SizedBox(width: 20),
              Text(
                "Add participants",
                style: TextStyle(
                    color: Colors.grey, fontSize: 20),
              ),
            ]),
          ),
        ) : Container(),
        Container(
            alignment: Alignment.center,
            child: brosInBroupList()),
      ],
    );
  }

  Widget muteChatWidget() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
        ),
        onPressed: () {
          chat.isMuted()
              ? showDialogUnMuteBroup(context)
              : showDialogMuteBroup(context);
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  chat.isMuted()
                      ? Icons.volume_up
                      : Icons.volume_mute,
                  color: chat.isMuted()
                      ? Colors.grey
                      : Colors.red),
              SizedBox(width: 20),
              chat.isMuted()
                  ? Text(
                'Unmute Broup',
                style: simpleTextStyle(),
              )
                  : Text(
                'Mute Broup',
                style: simpleTextStyle(),
              ),
            ]));
  }

  Widget blockBroupWidget() {
    // only for private messages, basically the same as leaving the broup
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
        ),
        onPressed: () {
          showDialogBlockBro(context, chat.getBroupName());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block,
                  color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Block Bro',
                style: simpleTextStyle(),
              ),
            ]));
  }

  Widget leaveBroupWidget() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
        ),
        onPressed: () {
          showDialogExitBroup(context, chat.getBroupName());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.exit_to_app,
                  color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Leave Broup',
                style: simpleTextStyle(),
              ),
            ]));
  }

  Widget chatDetailWidget() {
    return Container(
      child: Column(
          children: [
            chatAliasWidget(),
            SizedBox(height: 20),
            chatColourWidget(),
            SizedBox(height: 20),
            broupDescriptionWidget(),
            SizedBox(height: 50),
            chat.private ? Container() : chatDetailsParticipants(),
            SizedBox(height: 10),
            muteChatWidget(),
            SizedBox(height: 10),
            chat.private ? blockBroupWidget() : leaveBroupWidget(),
            SizedBox(height: 10),
      ]),
    );
  }

  Widget reportBroupWidget() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(Colors.red),
        ),
        onPressed: () {
          showDialogReport(context, chat.getBroupNameOrAlias());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.thumb_down, color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Report Broup',
                style: simpleTextStyle(),
              ),
            ]));
  }

  Widget shownDetails() {
    if (chat.isRemoved()) {
      return broHasLeft();
    } else {
      return chatDetailWidget();
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
          appBar: appBarChatDetails(),
          body: Container(
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    broCastLogo(),
                    broupNameHeader(),
                    SizedBox(height: 20),
                    shownDetails(),
                    reportBroupWidget(),
                    SizedBox(height: 200),
                  ]),
                ),
              ),
            ]),
          )),
    );
  }

  void exitBroup() {
    print("going to leave the broup");
    AuthServiceSocial().leaveBroup(chat.broupId).then((value) {
      if (value) {
        setState(() {
          chat.removeBro(settings.getMe()!.getId());
          chat.removed = true;
          amountInGroup = chat.getBroupBros().length;
          navigateToHome(context, settings);
        });
      }
    });
    Navigator.of(context).pop();
  }

  showDialogBlockBro(BuildContext context, String broName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Block Bro $broName!"),
          content: new Text("Are you sure you want to block this bro? The former bro will no longer be able to send you messages."),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Block"),
              onPressed: () {
                exitBroup();
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogExitBroup(BuildContext context, String broupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Leave Broup $broupName!"),
          content: new Text("Are you sure you want to leave this broup?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Leave Broup"),
              onPressed: () {
                exitBroup();
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogReport(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Report broup $chatName!"),
          content: new Text(
              "Are you sure you want to report this broup? The most recent messages from this broup will be forwarded to Zwaar developers to assess possible deletion of the broup. This broup and the messages will be removed from your bro list and the former broup can't send you messages anymore. This former broup will not be notified of the report."),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Report"),
              onPressed: () {
                reportTheBroup();
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogDelete(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Delete broup $chatName!"),
          content: new Text("Are you sure you want to delete this broup?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Delete"),
              onPressed: () {
                deleteTheBroup();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTheBroup() {
    // deleteBroup.deleteBroup(settings.getToken(), chat.id).then((val) {
    //   if (val is Broup) {
    //     Broup deletedBroup = val;
    //     broList.deleteChat(deletedBroup);
    //     storage.deleteChat(deletedBroup).then((value) {
    //       Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => BroCastHome(key: UniqueKey())));
    //     });
    //   } else {
    //     if (val == "an unknown error has occurred") {
    //       showToastMessage("An unknown error has occurred");
    //     } else {
    //       showToastMessage("There was an error with the server, we apologize for the inconvenience.");
    //     }
    //   }
    // });
    Navigator.of(context).pop();
  }

  void reportTheBroup() {
    // reportBro.reportBroup(settings.getToken(), chat.id).then((val) {
    //   if (val is Broup) {
    //     Broup broupToRemove = val;
    //     broList.deleteChat(broupToRemove);
    //     storage.deleteChat(broupToRemove).then((value) {
    //       Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //               builder: (context) => BroCastHome(key: UniqueKey())));
    //     });
    //   } else {
    //     if (val == "an unknown error has occurred") {
    //       showToastMessage("An unknown error has occurred");
    //     } else {
    //       showToastMessage("There was an error with the server, we apologize for the inconvenience.");
    //     }
    //   }
    // });
    Navigator.of(context).pop();
  }

  void showDialogUnMuteBroup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Unmute notifications?"),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Unmute"),
                onPressed: () {
                  unmuteTheBroup();
                },
              ),
            ],
          );
        });
  }

  void showDialogMuteBroup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 0;
          return AlertDialog(
            title: new Text("Mute notifications for..."),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(4, (int index) {
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
                            ? Container(child: Text("1 hour"))
                            : Container(),
                        index == 1
                            ? Container(child: Text("8 hours"))
                            : Container(),
                        index == 2
                            ? Container(child: Text("1 week"))
                            : Container(),
                        index == 3
                            ? Container(child: Text("Indefinitely"))
                            : Container(),
                      ]),
                    );
                  }),
                );
              },
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text("Mute"),
                onPressed: () {
                  muteTheBroup(selectedRadio);
                },
              ),
            ],
          );
        });
  }

  void unmuteTheBroup() {
    // socketServices.socket.emit("message_event_change_broup_mute", {
    //   "token": settings.getToken(),
    //   "broup_id": chat.id,
    //   "bro_id": settings.getBroId(),
    //   "mute": -1
    // });
    Navigator.of(context).pop();
  }

  void muteTheBroup(int selectedRadio) {
    // socketServices.socket.emit("message_event_change_broup_mute", {
    //   "token": settings.getToken(),
    //   "broup_id": chat.id,
    //   "bro_id": settings.getBroId(),
    //   "mute": selectedRadio
    // });
    Navigator.of(context).pop();
  }
}
