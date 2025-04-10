import 'dart:convert';
import 'dart:typed_data';
import 'package:brocast/utils/secure_storage.dart';
import 'package:brocast/utils/settings.dart';
import 'package:brocast/utils/socket_services.dart';
import 'package:brocast/utils/storage.dart';
import 'package:brocast/utils/utils.dart';
import 'package:brocast/views/chat_view/chat_details/chat_details.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import '../../../objects/me.dart';
import '../../../services/auth/auth_service_settings.dart';
import '../../objects/broup.dart';
import '../../objects/message.dart';
import '../camera_page/camera_page.dart';
import '../ui_util/crop/controller.dart';
import '../ui_util/crop/crop.dart';

class ChangeAvatar extends StatefulWidget {
  final bool isMe;  // Indicates that you're changing your own profile or a broup photo
  final Uint8List avatar;
  final bool isDefault;
  final Broup? chat;

  ChangeAvatar({
    required Key key,
    required this.isMe,
    required this.avatar,
    required this.isDefault,
    this.chat
  }) : super(key: key);

  @override
  _ChangeAvatarState createState() => _ChangeAvatarState();
}

class _ChangeAvatarState extends State<ChangeAvatar> {

  late Settings settings;
  bool showEmojiKeyboard = false;
  bool isLoading = false;

  late bool isDefault;

  late CropController cropController;

  late Uint8List imageMain;
  late Uint8List imageCrop;

  bool changesMade = false;

  @override
  void initState() {
    settings = Settings();
    imageMain = widget.avatar;
    imageCrop = widget.avatar;
    isDefault = widget.isDefault;
    cropController = CropController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  navigateBackToChatDetails() {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChatDetails(
          key: UniqueKey(),
          chat: widget.chat!
        )
      ),
    );
  }

  void backButtonFunctionality() {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
    } else {
      if (widget.isMe) {
        navigateToProfile(context, settings);
      } else {
        if (widget.chat != null) {
          navigateBackToChatDetails();
        } else {
          navigateToHome(context, settings);
        }
      }
    }
  }

  imageLoaded() async {
    isLoading = true;
    FilePickerResult? picked = await FilePicker.platform.pickFiles(withData: true);

    if (picked != null) {
      String? extension = picked.files.first.extension;
      if (extension != "png" && extension != "jpg" && extension != "jpeg") {
        showToastMessage("Please pick a png or jpeg file");
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          imageCrop = picked.files.first.bytes!;
          imageMain = picked.files.first.bytes!;
          cropController.image = imageMain;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  saveNewAvatar() {
    if (widget.avatar == imageCrop) {
      if (widget.isMe) {
        showToastMessage("the avatar remains the same");
        navigateToProfile(context, settings);
      } else {
        showToastMessage("the avatar remains the same");
        navigateBackToChatDetails();
      }
      return;
    }
    setState(() {
      isLoading = true;
    });
    // first downsize to 512 x 512
    image.Image regular = image.decodePng(imageCrop)!;
    int width = regular.width;
    if (width > 512) {
      regular = image.copyResize(regular, width: 512);
    }
    Uint8List regularImage = image.encodePng(regular);
    String newAvatarRegular = base64Encode(regularImage);
    if (widget.isMe) {
      AuthServiceSettings()
          .changeAvatar(newAvatarRegular)
          .then((response) {
        Uint8List changedAvatar = base64Decode(newAvatarRegular);
        isLoading = false;
        if (response.getResult()) {
          Settings settings = Settings();
          if (settings.getMe() != null) {
            Me me = settings.getMe()!;
            // Avatar update works, we update the avatar in the Me object
            // No need to retrieve it since we know what it is.
            me.setAvatar(changedAvatar);
            me.setAvatarDefault(false);
            SecureStorage().setAvatar(newAvatarRegular);
            SecureStorage().setAvatarDefault("0");
            Storage().updateBro(me);
            navigateToProfile(context, settings);
          }
        } else {
          showToastMessage(response.getMessage());
        }
      });
    } else {
      if (widget.chat != null) {
        SocketServices().setWeChangedAvatar(widget.chat!.broupId);
        AuthServiceSettings()
            .changeAvatarBroup(newAvatarRegular, widget.chat!.broupId)
            .then((response) {
          // We will receive an avatar update via the socket.
          // Indicate to not update because we changed it.
          Uint8List changedAvatar = base64Decode(newAvatarRegular);
          isLoading = false;
          if (response.getResult()) {
            Me? me = Settings().getMe();
            if (me != null) {
              widget.chat!.setAvatarDefault(false);
              widget.chat!.setAvatar(changedAvatar);
              for (Broup broup in me.broups) {
                if (broup.getBroupId() == widget.chat!.broupId) {
                  broup.setAvatar(changedAvatar);
                  broup.setAvatarDefault(false);
                  Storage().updateBroup(broup);
                  navigateBackToChatDetails();
                  return;
                }
              }
            }
          } else {
            showToastMessage(response.getMessage());
          }
        });
      }
    }
  }

  resetDefaultImage() {
    setState(() {
      isLoading = true;
    });
    if (widget.isMe) {
      AuthServiceSettings().resetAvatarMe().then((response) {
        isLoading = false;
        if (response.getResult()) {
          setState(() {
            String newAvatarString = response.getMessage().replaceAll(
                "\n", "");
            Uint8List newAvatar = base64Decode(
                response.getMessage().replaceAll("\n", ""));
            SecureStorage().setAvatar(newAvatarString);
            SecureStorage().setAvatarDefault("1");
            Settings settings = Settings();
            Me? me = settings.getMe();
            if (me != null) {
              me.setAvatar(newAvatar);
              me.setAvatarDefault(true);
              Storage().updateBro(me);
              navigateToProfile(context, settings);
            }
          });
        } else {
          showToastMessage(response.getMessage());
        }
      });
    } else {
      if (widget.chat != null) {
        SocketServices().setWeChangedAvatar(widget.chat!.broupId);
        AuthServiceSettings().resetAvatarBroup(widget.chat!.broupId).then((
            response) {
          isLoading = false;
          if (response.getResult()) {
            setState(() {
              String newAvatarString = response.getMessage().replaceAll(
                  "\n", "");
              Uint8List newAvatar = base64Decode(newAvatarString);
              widget.chat!.setAvatarDefault(true);
              widget.chat!.setAvatar(newAvatar);
              Settings settings = Settings();
              if (settings.getMe() != null) {
                Me me = settings.getMe()!;
                for (Broup broup in me.broups) {
                  if (broup.getBroupId() == widget.chat!.broupId) {
                    broup.setAvatar(newAvatar);
                    broup.setAvatarDefault(false);
                    Storage().updateBroup(broup);
                    navigateBackToChatDetails();
                    return;
                  }
                }
              }
              Storage().updateBroup(widget.chat!);
              navigateBackToChatDetails();
            });
          } else {
            showToastMessage(response.getMessage());
          }
        });
      }
    }
  }

  PreferredSize appBarChangeAvatar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
          backgroundColor: Color(0xff145C9E),
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                backButtonFunctionality();
              }),
          title: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                  "Change Avatar",
                  style: TextStyle(color: Colors.white)
              )),
          actions: [
            PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (item) => onSelect(context, item),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(value: 0, child: Text("Settings")),
                  PopupMenuItem<int>(value: 1, child: Text("Profile")),
                  PopupMenuItem<int>(value: 2, child: Text("Home"))
                ])
          ]),
    );
  }

  void onSelect(BuildContext context, int item) {
    switch (item) {
      case 0:
        navigateToSettings(context, settings);
        break;
      case 1:
        navigateToProfile(context, settings);
        break;
      case 2:
        navigateToHome(context, settings);
        break;
    }
  }

  Widget cropWidget(double cropHeight) {
    return SizedBox(
      width: cropHeight,
      height: cropHeight,
      child: Crop(
        image: imageMain,
        controller: cropController,
        hexCrop: true,
        onStatusChanged: (status) {
          changesMade = true;
          if (status == CropStatus.cropping || status == CropStatus.loading) {
            isLoading = true;
          } else if (status == CropStatus.ready) {
            isLoading = false;
          }
        },
        onResize: (imageData) {
          changesMade = true;
          setState(() {
            imageCrop = imageData;
            imageMain = imageData;
            cropController.image = imageData;
          });
        },
        onCropped: (image) {
          setState(() {
            imageCrop = image;
          });
        },
      ),
    );
  }

  takePicture() async {
    availableCameras().then((value) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => CameraPage(
            key: UniqueKey(),
            chat: widget.chat,
            isMe: widget.isMe,
            cameras: value,
          )
        ),
      ).then((value) async {
        if (value != null) {
          isLoading = true;
          setState(() {
            imageCrop = value;
            imageMain = value;
            cropController.image = imageMain;
          });
        };
      });
    });
  }

  Widget uploadNewImageButton(double buttonWidth, double buttonHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: takePicture,
          iconSize: 60,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.camera_alt, color: Colors.blue),
        ),
        IconButton(
          onPressed: imageLoaded,
          iconSize: 60,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.image, color: Colors.blue),
        )
      ],
    );
  }

  Widget resetDefaultImageButton(double buttonWidth, double buttonHeight) {
    return !isDefault ? SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          if (!isLoading) {
            resetDefaultImage();
          }
        },
        style: buttonStyle(false, Colors.blueGrey),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'reset default image',
            style: simpleTextStyle(),
          ),
        ),
      ),
    ) : SizedBox(
        width: buttonWidth,
        height: buttonHeight,
    );
  }

  Widget saveImageButton(double buttonWidth, double buttonHeight) {
    return changesMade ? SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          if (!isLoading) {
            saveNewAvatar();
          }
        },
        style: buttonStyle(false, Colors.blue),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Save new avatar',
            style: simpleTextStyle(),
          ),
        ),
      ),
    ) : Container();
  }

  Widget changeAvatar(double width, double height) {
    double totalHeightPadding = 30 * 4;
    double cropResultWidth = height/4;
    double sidePadding = 20;
    double buttonWidth = (width / 3) * 2;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight = 50;
    double remainingHeight = height - (totalHeightPadding + (2 * cropResultWidth) + statusBarHeight + appBarHeight);
    double buttonHeight = remainingHeight / 4;

    return Container(
      height: height,
      margin: EdgeInsets.only(left: sidePadding, right: sidePadding),
      child: Column(
          children: [
            SizedBox(height: 10),
            cropWidget(cropResultWidth),
            SizedBox(height: 10),
            SizedBox(
                width: width,
                height: 30,
                child: Text(
                    "Result:",
                    textAlign: TextAlign.center,
                    style: simpleTextStyle()
                )
            ),
            avatarBox(
                cropResultWidth,
                cropResultWidth,
                imageCrop
            ),
            SizedBox(height: buttonHeight/3),
            uploadNewImageButton(buttonWidth, buttonHeight),
            SizedBox(height: buttonHeight/3),
            saveImageButton(buttonWidth, buttonHeight),
            SizedBox(height: buttonHeight/3),
            resetDefaultImageButton(buttonWidth, buttonHeight),
            SizedBox(height: 10),
          ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          backButtonFunctionality();
        }
      },
      child: Scaffold(
        appBar: appBarChangeAvatar(context),
        body: Stack(
          children: [
            isLoading
                ? Container(child: Center(child: CircularProgressIndicator()))
                : Container(),
            changeAvatar(width, height),
          ]
        )
      )
    );
  }
}
