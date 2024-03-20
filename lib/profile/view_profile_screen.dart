import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/auth/screen/login.dart';
import 'package:my_chat/helper/dialog.dart';
import 'package:my_chat/helper/my_date_util.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.user.name,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: mq.width,
                ),
                Stack(
                  children: [
                    //Local image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        height: mq.height * .2,
                        width: mq.height * .2,
                        fit: BoxFit.fill,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>
                            CircleAvatar(child: Icon(Icons.person)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * .02,
                ),
                Text(widget.user.email),
                SizedBox(
                  height: mq.height * .05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('About: '),
                    Text('${widget.user.about}'),
                  ],
                ),
                SizedBox(
                  height: mq.height * .08,
                ),
                SizedBox(
                  height: mq.height * .08,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Joined on: '),
            Text(
                '${MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true)}'),
          ],
        ),
      ),
    );
  }
}
