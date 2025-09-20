import 'package:flutter/material.dart';

import '../../../objects/bro.dart';
import '../../../utils/utils.dart';

class LocationSharingOverview extends StatefulWidget {
  final List<LocationSharingOverviewData> emojiOverviewDataList;
  final VoidCallback onOutsideTap;

  const LocationSharingOverview({
    required this.emojiOverviewDataList,
    required this.onOutsideTap,
    Key? key,
  }) : super(key: key);

  @override
  LocationSharingOverviewState createState() => LocationSharingOverviewState();
}

class LocationSharingOverviewState extends State<LocationSharingOverview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        GestureDetector(
          onTap: widget.onOutsideTap,
          child: Container(
            color: Colors.transparent,
          ),
        ),
        Align(
          alignment: Alignment(0, -0.2),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: widget.onOutsideTap,
                      child: Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '${widget.emojiOverviewDataList.length} Sharing',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.emojiOverviewDataList.length,
                          itemBuilder: (context, index) {
                            LocationSharingOverviewData data = widget.emojiOverviewDataList[index];
                            return Center(
                              child: ListTile(
                                leading: avatarBox(50, 50, data.bro.avatar),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data.bro.getFullName()),
                                    Text(
                                      data.locationInformation,
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ]
            ),
          ),
        ),
      ],
    );
  }
}

class LocationSharingOverviewData {
  final Bro bro;
  final String locationInformation;
  LocationSharingOverviewData({
    required this.bro,
    required this.locationInformation,
  });
}