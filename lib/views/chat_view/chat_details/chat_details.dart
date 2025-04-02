import 'dart:convert';

import 'package:brocast/objects/broup.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/bro_home/bro_home_change_notifier.dart';
import "package:flutter/material.dart";
import 'package:flutter/scheduler.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:brocast/constants/route_paths.dart' as routes;
import '../../../objects/bro.dart';
import '../../../objects/me.dart';
import '../../../objects/message.dart';
import '../../../services/auth/auth_service_settings.dart';
import '../../../services/auth/auth_service_social.dart';
import '../../../utils/notification_controller.dart';
import '../../../utils/storage.dart';
import '../../bro_home/bro_home.dart';
import '../../bro_profile/bro_profile.dart';
import '../../bro_settings/bro_settings.dart';
import '../../change_avatar/change_avatar.dart';
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

  late Storage storage;

  double iconSize = 30;

  bool meAdmin = false;
  Map<String, bool> broAdminStatus = {};
  // Not every bro in a broup will be in your personal bro list
  // In that case different options will be available
  Map<String, bool> broAddedStatus = {};

  @override
  void initState() {
    super.initState();
    storage = Storage();
    amountInGroup = widget.chat.getBroIds().length;
    socketServices.addListener(socketListener);

    chatDescriptionController.text = widget.chat.broupDescription;
    chatAliasController.text = widget.chat.alias;

    checkAdmin();

    circleColorPickerController = CircleColorPickerController(
      initialColor: widget.chat.getColor(),
    );
    currentColor = widget.chat.getColor();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

  }

  checkAdmin() {
    meAdmin = false;
    for (Bro bro in widget.chat.getBroupBros()) {
      broAdminStatus[bro.id.toString()] = false;
      broAddedStatus[bro.id.toString()] = false;
    }
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

  participantChange() {
    checkAdmin();
    amountInGroup = widget.chat.getBroupBros().length;
    setState(() {});
  }

  socketListener() {
    if (widget.chat.getBroupBros().length < widget.chat.broIds.length) {
      // There is probably a new bro in the broup.
      // It would have retrieved the bros in the previous screen, so there was
      // a new bro id added via sockets.
      // We will find which id and retrieve it.
      // First we will check if it's in the DB
      List<int> broIdsToRetrieve = [...widget.chat.getBroIds()];
      for (Bro bro in widget.chat.getBroupBros()) {
        broIdsToRetrieve.remove(bro.id);
      }
      print("ids missing from broup: $broIdsToRetrieve");
      storage.fetchBros(broIdsToRetrieve).then((value) {
        if (value.isNotEmpty) {
          for (Bro bro in value) {
            widget.chat.addBro(bro);
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
              widget.chat.addBro(bro);
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
      AuthServiceSocial().addNewBro(broId).then((response) {
        if (response.getResult()) {
          // The broup added, move to the home screen where it will be shown
          navigateToHome(context, settings);
        } else {
          showToastMessage(response.getMessage());
        }
      });
    } else if (delta == 2) {
      print("making bro admin");
      AuthServiceSocial().makeBroAdmin(widget.chat.broupId, broId).then((value) {
        if (value) {
          setState(() {
            widget.chat.addAdminId(broId);
            checkAdmin();
          });
        }
      });
    } else if (delta == 3) {
      print('dismissing bro from admin');
      AuthServiceSocial().dismissBroAdmin(widget.chat.broupId, broId).then((value) {
        if (value) {
          setState(() {
            widget.chat.removeAdminId(broId);
            checkAdmin();
          });
        }
      });
    } else if (delta == 4) {
      print('Remove bro from chat.');
      AuthServiceSocial().removeBroToBroup(widget.chat.broupId, broId).then((value) {
        if (value) {
          setState(() {
            widget.chat.removeBro(broId);
            // TODO: reset the bros on the broup?
            // widget.chat.retrievedBros = false;
            widget.chat.checkedRemainingBros = false;
            amountInGroup = widget.chat.getBroupBros().length;
            print("bro has been removed :'(");
          });
        }
      });
    }
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
      navigateToChat(context, settings, widget.chat);
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
                  Icon(Icons.arrow_back, color: getTextColor(widget.chat.getColor())),
              onPressed: () {
                backButtonFunctionality();
              }),
          backgroundColor: widget.chat.getColor(),
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
        navigateToChat(context, settings, widget.chat);
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
      changeAlias = false;
    });
  }

  void onTapAliasField() {
    previousAlias = chatAliasController.text;
    focusNodeAlias.requestFocus();
    setState(() {
      changeAlias = true;
      changeDescription = false;
    });
  }

  updateDescription() {
    if (previousDescription != chatDescriptionController.text) {
      String newBroupDescription = chatDescriptionController.text;
      AuthServiceSettings().changeDescriptionBroup(widget.chat.getBroupId(), newBroupDescription).then((val) {
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
      AuthServiceSettings().changeAliasBroup(widget.chat.getBroupId(), newBroupAlias).then((val) {
        if (val) {
          // Since this is only visible for the bro
          // we don't get an update via sockets
          // So we update it once we have received a response from the server
          widget.chat.alias = newBroupAlias;
          storage.updateBroup(widget.chat);
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
    if (currentColor != widget.chat.getColor()) {
      String newBroupColour = toHex(currentColor);
      AuthServiceSettings().changeColourBroup(widget.chat.getBroupId(), newBroupColour).then((val) {
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

  onTapPhotoField() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ChangeAvatar(
              key: UniqueKey(),
              isMe: false,
              avatar: widget.chat.avatar!,
              isDefault: widget.chat.avatarDefault,
              chat: widget.chat,
            )));
  }

  Widget brosInBroupList() {
    return widget.chat.getBroupBros().isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.chat.getBroupBros().length,
            itemBuilder: (context, index) {
              return BroTileDetails(
                  key: UniqueKey(),
                  bro: widget.chat.getBroupBros()[index],
                  broAdmin: broAdminStatus[widget.chat.getBroupBros()[index].id.toString()]!,
                  broAdded: broAddedStatus[widget.chat.getBroupBros()[index].id.toString()]!,
                  broupId: widget.chat.broupId,
                  userAdmin: meAdmin,
                  broHandling: broHandling
              );
            })
        : Container();
  }

  addParticipant() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BroupAddParticipant(key: UniqueKey(), chat: widget.chat)));
  }

  Widget broCastLogo() {
    return Container(
        alignment: Alignment.center,
        child:
        Image.asset("assets/images/brocast_transparent.png"));
  }

  Widget broupAvatar() {
    double width = MediaQuery.of(context).size.width;
    double avatarWidth = (width/8)*5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: iconSize*1.5,
          height: iconSize*1.5,
        ),
        avatarBox(avatarWidth, avatarWidth, widget.chat.getAvatar()),
      meAdmin ? Container(
          width: iconSize*1.5,
          height: iconSize*1.5,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(
                  Icons.camera_alt,
                  color: Colors.white
              ),
              onPressed: () {
                onTapPhotoField();
              }),
        ) : Container(
        width: iconSize,
        height: iconSize,)
      ],
    );
  }

  Widget broupNameHeader() {
    if (widget.chat.alias.isNotEmpty) {
      return Column(children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              "${widget.chat.alias}",
              style: TextStyle(
                  color: Colors.white, fontSize: 25),
            )),
        SizedBox(height: 10),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: Text(
              "${widget.chat.getBroupName()}",
              style: TextStyle(
                  color: Colors.white, fontSize: 16),
            ))
      ]);
    } else {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          child: Text(
            "${widget.chat.getBroupName()}",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ));
    }
  }

  bool isBlocker() {
    if (widget.chat.private) {
      for (int broId in widget.chat.getAdminIds()) {
        if (broId == settings.getMe()!.getId()) {
          return true;
        }
      }
    }
    return false;
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
        isBlocker() ? Container(
          child: TextButton(
              style: ButtonStyle(
                foregroundColor:
                WidgetStateProperty.all<Color>(
                    Colors.red),
              ),
              onPressed: () {
                showDialogUnBlock(
                    context, widget.chat.getBroupNameOrAlias());
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_open_outlined, color: Colors.red),
                    SizedBox(width: 20),
                    Text(
                      'Unblock Bro',
                      style: simpleTextStyle(),
                    ),
                  ])),
        ) : Container(),
        Container(
          child: TextButton(
              style: ButtonStyle(
                foregroundColor:
                WidgetStateProperty.all<Color>(
                    Colors.red),
              ),
              onPressed: () {
                showDialogDelete(
                    context, widget.chat.getBroupNameOrAlias());
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 20),
                    Text(
                      widget.chat.private ? 'Delete Bro' : 'Delete Broup',
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
          width: iconSize*1.5,
          height: iconSize*1.5,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.check,
                  color: Colors.white),
              onPressed: () {
                updateAlias();
              }),
        )
            : Container(
          width: iconSize*1.5,
          height: iconSize*1.5,
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
                      color: widget.chat.getColor(),
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
          width: iconSize*1.5,
          height: iconSize*1.5,
          child: IconButton(
              iconSize: iconSize,
              icon: Icon(Icons.check,
                  color: Colors.white),
              onPressed: () {
                updateDescription();
              }),
        )
            : Container(
          width: iconSize*1.5,
          height: iconSize*1.5,
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
          widget.chat.isMuted()
              ? showDialogUnMuteBroup(context)
              : showDialogMuteBroup(context);
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  widget.chat.isMuted()
                      ? Icons.volume_up
                      : Icons.volume_mute,
                  color: widget.chat.isMuted()
                      ? Colors.grey
                      : Colors.red),
              SizedBox(width: 20),
              widget.chat.isMuted()
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
          showDialogBlockBro(context, widget.chat.getBroupName());
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
          showDialogExitBroup(context, widget.chat.getBroupName());
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

  clearMessagesWidget() {
    return TextButton(
        style: ButtonStyle(
          foregroundColor:
          WidgetStateProperty.all<Color>(
              Colors.red),
        ),
        onPressed: () {
          showDialogClearMessages(context, widget.chat.getBroupNameOrAlias());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  Icons.cleaning_services_sharp,
                  color: Colors.red),
              SizedBox(width: 20),
              Text(
                'Clear Messages',
                style: simpleTextStyle(),
              )
            ]
        )
    );
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
            widget.chat.private ? Container() : chatDetailsParticipants(),
            SizedBox(height: 10),
            muteChatWidget(),
            SizedBox(height: 10),
            widget.chat.private ? blockBroupWidget() : leaveBroupWidget(),
            SizedBox(height: 10),
            clearMessagesWidget(),
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
          showDialogReport(context, widget.chat.getBroupNameOrAlias());
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.thumb_down, color: Colors.red),
              SizedBox(width: 20),
              Text(
                widget.chat.private ? "Report Bro" : "Report broup",
                style: simpleTextStyle(),
              ),
            ]));
  }

  Widget shownDetails() {
    if (widget.chat.isRemoved()) {
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
                    broupAvatar(),
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
    AuthServiceSocial().leaveBroup(widget.chat.broupId).then((value) {
      if (value) {
        setState(() {
          widget.chat.unreadMessages = 0;
          if (!widget.chat.private) {
            widget.chat.removeBro(settings.getMe()!.getId());
          } else {
            // In a private chat when you "leave" the broup you block the other bro
            // We use the admin Id to indicate who did the blocking.
            // This is the only bro that can unblock it later.
            widget.chat.addAdminId(settings.getMe()!.getId());
            widget.chat.blocked = true;
          }
          widget.chat.removed = true;
          amountInGroup = widget.chat.getBroupBros().length;
          // No longer part of the broup, so leave the socket room
          socketServices.leaveRoomBroup(widget.chat.broupId);
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

  clearMessagesBroup() async {
    await storage.deleteChatMessages(widget.chat.broupId);
    widget.chat.messages = [];
    showToastMessage("Messages cleared in broup ${widget.chat.getBroupNameOrAlias()}");
    Navigator.of(context).pop();
  }

  void showDialogClearMessages(BuildContext context, String broupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Clear Messages in $broupName!"),
          content: new Text("Are you sure you want to clear all the messages in this broup"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Clear messages"),
              onPressed: () {
                clearMessagesBroup();
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
          title: new Text(
              widget.chat.private ? "Report bro $chatName!" : "Report broup $chatName!",
          ),
          content: new Text(
              widget.chat.private
                  ? "Are you sure you want to report this bro? The most recent messages between you and this bro will be forwarded to Zwaar developers to assess possible actions against the bro. This bro and the messages will be removed from your bro list and the former bro can't send you messages anymore. This former bro will not be notified of the report."
                  : "Are you sure you want to report this broup? The most recent messages from this broup will be forwarded to Zwaar developers to assess possible deletion of the broup. This broup and the messages will be removed from your bro list and the former broup can't send you messages anymore. This former broup will not be notified of the report."),
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

  showDialogUnBlock(BuildContext context, String chatName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Unblock bro $chatName!"),
          content: new Text("Are you sure you want to unblock this bro?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Unblock"),
              onPressed: () {
                UnblockTheBro();
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
          title: new Text(
              widget.chat.private ? "Delete bro $chatName!" : "Delete broup $chatName!",
          ),
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

  UnblockTheBro() {
    Navigator.of(context).pop();
    int unblockBroId = -1;
    for (int broId in widget.chat.getBroIds()) {
      if (broId != Settings().getMe()!.getId()) {
        unblockBroId = broId;
      }
    }
    if (unblockBroId == -1) {
      showToastMessage("something went wrong with unblocking the bro. Please try again later.");
      return;
    }
    AuthServiceSocial().unblockBro(widget.chat.broupId, unblockBroId).then((value) {
      if (value) {
        setState(() {
          socketServices.leaveRoomBroup(widget.chat.broupId);
          widget.chat.removed = false;
          widget.chat.blocked = false;
          widget.chat.adminIds = [];
          widget.chat.newMessages = true;
          // Slight delay to not interfere with anything.
          Future.delayed(Duration(milliseconds: 200), () {
            socketServices.joinRoomBroup(widget.chat.broupId);
            widget.chat.joinedBroupRoom = true;
            navigateToChat(context, settings, widget.chat);
          });
        });
      } else {
        showToastMessage("something went wrong with unblocking the bro. Please try again later.");
      }
    });
  }

  void deleteTheBroup() {
    AuthServiceSocial().deleteBroup(widget.chat.broupId).then((value) {
      if (value) {
        setState(() {
          storage.deleteChat(widget.chat.broupId);
          Settings().getMe()!.removeBroup(widget.chat.broupId);
          navigateToHome(context, settings);
        });
      }
    });
    Navigator.of(context).pop();
  }

  void reportTheBroup() {
    // get the last 40 (or less) messages from this broup
    List<Message> reportMessages = widget.chat.messages.sublist(0, widget.chat.messages.length < 40 ? widget.chat.messages.length : 40);
    List<Map<String, dynamic>> reportMessagesJson = [];
    for (Message message in reportMessages) {
      reportMessagesJson.add(message.toDbMap());
    }
    List<String> sending = reportMessagesJson.map((map) => jsonEncode(map)).toList();
    String broupName = widget.chat.getBroupName();
    AuthServiceSocial().reportBroup(widget.chat.broupId, sending, broupName).then((value) {
      if (value) {
        setState(() {
          widget.chat.removed = true;
          widget.chat.blocked = true;
          widget.chat.deleted = true;
          navigateToHome(context, settings);
        });
      } else {
        showToastMessage("Reporting the broup failed at this time.");
      }
    });
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
                  muteTheBroup(-1);
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

  muteTheBroup(int muteValue) {
    AuthServiceSocial().muteBroup(widget.chat.broupId, muteValue).then((value) {
      if (value) {
        setState(() {
          widget.chat.setMuted(muteValue >= 0);
        });
        // 0 is 1 hour 1 is 8 hours 2 is 1 week 3 is indefinitely
        DateTime now = DateTime.now().toUtc();
        if (muteValue == 0) {
          widget.chat.setMuteValue(now.add(Duration(hours: 1)).toString());
          widget.chat.checkMute();
        } else if (muteValue == 1) {
          widget.chat.setMuteValue(now.add(Duration(hours: 8)).toString());
          widget.chat.checkMute();
        } else if (muteValue == 2) {
          widget.chat.setMuteValue(now.add(Duration(days: 7)).toString());
          widget.chat.checkMute();
        }
        // We update the localDB and the current list but only the mute values
        storage.fetchBroup(widget.chat.broupId).then((dbBroup) {
          if (dbBroup != null) {
            dbBroup.mute = widget.chat.mute;
            dbBroup.muteValue = widget.chat.muteValue;
            storage.updateBroup(dbBroup).then((value) {
              print("Broup muting updated in local DB");
              BroHomeChangeNotifier().notify();
            });
          }
        });
        navigateToHome(context, settings);
      } else {
        showToastMessage("Broup muting failed at this time.");
      }
    });
    Navigator.of(context).pop();
  }
}
