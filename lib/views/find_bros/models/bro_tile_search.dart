import 'package:flutter/material.dart';

import '../../../objects/bro.dart';
import '../../../utils/new/utils.dart';

class BroTileSearch extends StatelessWidget {
  final Bro bro;
  final void Function(int) addNewBro;

  BroTileSearch(this.bro, this.addNewBro);

  addBro() {
    addNewBro(bro.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            child: avatarBox(70, 70, bro.avatar),
          ),
          Container(
              padding: EdgeInsets.only(left: 5),
              width: MediaQuery.of(context).size.width - 157,
              child: Text(bro.getFullName(),
                  overflow: TextOverflow.ellipsis, style: simpleTextStyle())),
          Spacer(),
          Container(
            width: 62,
            child: GestureDetector(
              onTap: () {
                addBro();
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Add")),
            ),
          )
        ],
      ),
    );
  }
}
