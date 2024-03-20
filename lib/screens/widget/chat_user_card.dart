import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/chating/chat_screen.dart';
import 'package:my_chat/chating/models/message_model.dart';
import 'package:my_chat/helper/my_date_util.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user_model.dart';
import 'package:my_chat/profile/widget/profile_dialog.dart';

class ChatUserCard extends StatelessWidget {
  final ChatUserModel user;
  ChatUserCard({super.key, required this.user});
  MessageModel? _message;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
            onTap: () {
              // for navigating to chat screen
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(
                            user: user,
                          )));
            },
            child: StreamBuilder(
                stream: Apis.getLastMessage(user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final messagesList = data
                          ?.map((e) => MessageModel.fromJson(e.data()))
                          .toList() ??
                      [];
                  if (messagesList.isNotEmpty) _message = messagesList[0];
                  return ListTile(
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(
                                  user: user,
                                ));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: CachedNetworkImage(
                          height: mq.height * .055,
                          width: mq.height * .055,
                          imageUrl: user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(child: Icon(Icons.person)),
                        ),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'image'
                              : _message!.msg
                          : user.about,
                      maxLines: 1,
                    ),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != Apis.user.uid
                            ? Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Text(MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.send)),
                  );
                })));
  }
}
