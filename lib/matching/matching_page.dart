import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:strong_buddies_connect/matching/bloc/matching_bloc.dart';
import 'package:strong_buddies_connect/routes.dart';
import 'package:strong_buddies_connect/shared/models/buddy_pojo.dart';
import 'package:strong_buddies_connect/shared/models/current_user_pojo.dart';
import 'package:strong_buddies_connect/shared/services/auth_service.dart';
import 'package:strong_buddies_connect/shared/services/loader_service.dart';
import 'package:strong_buddies_connect/shared/services/user_collection.dart';
import 'package:strong_buddies_connect/chat/chat.dart';
import 'package:strong_buddies_connect/routes.dart';

class UserInfoPage extends StatefulWidget {
  UserInfoPage({Key key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final userCol = UserCollection();
  final auth = AuthService();
  final _controller = PageController();
  final _bloc = MatchingBloc(UserCollection(), AuthService());
  Loader _loader;

  @override
  void initState() {
    super.initState();
    _loader = Loader(context);
    _bloc.add(RequestBuddies());
    auth.getCurrentUser().then((onValue) {
      userCol.listenToChanges(onValue.uid, (buddies) {
        buddies.forEach((buddy) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: new Text("You have a match"),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.network(buddy.photoUrl, height: 200),
                    Text(buddy.displayName)
                  ],
                ),
                actions: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok'),
                  )
                ],
              );
            },
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.chatListPage),
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
      body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(children: <Widget>[
            Container(
              color: Color(0xFF4E4C50),
              width: double.infinity,
              height: double.infinity,
              child: Opacity(
                opacity: 0.80,
                child: Image.network(
                  'https://cdn.pixabay.com/photo/2017/08/07/14/02/people-2604151_960_720.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  width: double.infinity,
                  height: double.infinity,
                  child: BlocListener(
                    bloc: _bloc,
                    listener: (previous, state) {},
                    child: BlocBuilder<MatchingBloc, MatchingState>(
                      bloc: _bloc,
                      builder: (context, state) {
                        if (state is BuddyLoaded)
                          return buildBuddyMatch(
                              state.buddy, state.currentUser);
                        else if (state is OutOfBuddies)
                          return Container(
                            child: Center(
                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Text(
                                        "We're out of buddies at the moment",
                                      ),
                                    ),
                                    RaisedButton(
                                      onPressed:
                                          /*  () async {
                                        await AuthService().singOut();
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            Routes.loginPage,
                                            (_) => false);
                                      } */
                                          () {},
                                      child: Text('Sign Out'),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        return Container();
                      },
                    ),
                  )),
            )
          ])),
    );
  }

  Column buildBuddyMatch(
    Buddy potentialBuddyToBeMatchedWith,
    CurrentUser currentUser,
  ) {
    return Column(children: <Widget>[
      const SizedBox(height: 5),
      const Text('Buddies',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          )),
      const Spacer(),
      Card(
        elevation: 2,
        child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    height: 400,
                    child: PageView.builder(
                        itemCount:
                            potentialBuddyToBeMatchedWith.pictures.length,
                        controller: _controller,
                        itemBuilder: (context, index) {
                          return Image.network(
                              potentialBuddyToBeMatchedWith.pictures[index],
                              fit: BoxFit.cover);
                        })),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      potentialBuddyToBeMatchedWith.displayName,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    )),
                Text(potentialBuddyToBeMatchedWith.gender,
                    style: TextStyle(fontSize: 12, color: Color(0xffa7a7a7))),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RichText(
                      text: TextSpan(
                    style: TextStyle(color: Color(0xffa7a7a7), fontSize: 15),
                    children: potentialBuddyToBeMatchedWith.workoutTypes
                        .map((workType) => TextSpan(
                            text: '$workType, ',
                            style:
                                currentUser.workoutTypes.indexOf(workType) != -1
                                    ? TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500)
                                    : null))
                        .toList(),
                  )),
                ),
              ],
            )),
      ),
      const Spacer(),
      Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Ink(
              decoration: const ShapeDecoration(
                  color: Color(0xffa6a2c0), shape: CircleBorder()),
              child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _bloc.add(RejectBuddy());
                  }),
            ),
            SizedBox(width: 40),
            Ink(
              decoration: const ShapeDecoration(
                  color: Color(0xffee5c5c), shape: CircleBorder()),
              child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    _bloc.add(MatchWithBuddy());
                  }),
            )
          ]),
        ),
      )
    ]);
  }
}