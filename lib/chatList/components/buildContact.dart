import 'package:flutter/material.dart';
import 'package:strong_buddies_connect/chat/chat.dart';
import 'package:strong_buddies_connect/shared/components/circle_image.dart';
import 'package:strong_buddies_connect/shared/components/status_circle.dart';
import 'package:strong_buddies_connect/shared/models/match_model.dart';

Widget buildContact(BuildContext context, Match match) {
  return GestureDetector(
      onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                    peerId: match.id,
                    peerAvatar: match.photoUrl,
                    displayName: match.displayName)),
          ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: CircleImage(
                    heigth: 50.0,
                    width: 50.0,
                    imageUrl: match.photoUrl,
                    radius: 25,
                  )),
              Positioned(
                  bottom: 8,
                  left: 40,
                  child: StatusCircle(
                    size: 10,
                    color: Colors.lightGreenAccent,
                  ))
            ]),
            SizedBox(
              width: 60,
              height: 50,
              child: Text(
                '${match.displayName}',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ));
}
