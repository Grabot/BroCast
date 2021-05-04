import 'package:brocast/services/socket_services.dart';
import 'package:brocast/utils/utils.dart';
import "package:flutter/material.dart";

class BroProfile extends StatefulWidget {

  final SocketServices socket;

  BroProfile({ Key key, this.socket }): super(key: key);

  @override
  _BroProfileState createState() => _BroProfileState();
}

class _BroProfileState extends State<BroProfile> {

  SocketServices socket;

  @override
  void initState() {
    super.initState();
    if (widget.socket == null) {
      socket = new SocketServices();
      socket.startSockConnection();
    } else {
      socket = widget.socket;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
              title: Container(
              alignment: Alignment.centerLeft,
              child: Text("Profile")
          ),
        ),
        body: Container(
          child: Text("Profile"),
      )
    );
  }
}

