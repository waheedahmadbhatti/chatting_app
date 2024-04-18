import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/chating/models/message_model.dart';
import 'package:my_chat/chating/widget/message_card.dart';
import 'package:my_chat/helper/my_date_util.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user_model.dart';
import 'package:my_chat/profile/view_profile_screen.dart';
import 'package:my_chat/screens/call/call_page.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<MessageModel> _messagesList = [];
  final TextEditingController _textEditingController = TextEditingController();
  // for storing value of showing or hiding emoji
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    String callerId = widget.user.id;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CallPage(
                                    userId: widget.user.id,
                                    userName: widget.user.name,
                                  )));
                    },
                    icon: Icon(Icons.videocam_outlined)),
              ],
            ),
            backgroundColor: Color(0xEADBE8F8),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: Apis.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _messagesList = data
                                    ?.map(
                                        (e) => MessageModel.fromJson(e.data()))
                                    .toList() ??
                                [];
                            return _messagesList.isEmpty
                                ? const Center(
                                    child: Text("No Data!"),
                                  )
                                : ListView.builder(
                                    reverse: true,
                                    itemCount: _messagesList.length,
                                    padding:
                                        EdgeInsets.only(top: mq.height * .01),
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return MessageCard(
                                        message: _messagesList[index],
                                      );
                                    });
                        }
                      }),
                ),
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )),
                // chat input field
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textEditingController,
                      // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(columns: 7, emojiSizeMax: 32),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

// app bar widget
  Widget _appbar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: Apis.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUserModel.fromJson(e.data())).toList() ??
                      [];
              return Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back_ios)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      height: mq.height * .05,
                      width: mq.width * .1,
                      fit: BoxFit.fill,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) =>
                          CircleAvatar(child: Icon(Icons.person)),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(list.isNotEmpty ? list[0].name : widget.user.name),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.green,
                                    )
                                  : SizedBox()
                              : SizedBox(),
                          Text(list.isNotEmpty
                              ? list[0].isOnline
                                  ? ' online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive)),
                        ],
                      )
                    ],
                  ),
                ],
              );
            }));
  }

//bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          FocusScope.of(context).unfocus();

                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      setState(() {
                        if (_showEmoji) _showEmoji = !_showEmoji;
                      });
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type here ...', border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Picking multiple images.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        // uploading &sending image one by one
                        for (var i in images) {
                          setState(() {
                            _isUploading = true;
                          });
                          await Apis.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.photo,
                        color: Colors.blueAccent,
                      )),
                  // pick image from camera
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          print('image path : ${image.path}');
                          setState(() {
                            _isUploading = true;
                          });
                          await Apis.sendChatImage(
                              widget.user, File(image.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blueAccent,
                      )),
                  //  SizedBox(width: mq.width*.02,)
                ],
              ),
            ),
          ),
          // send Message button
          MaterialButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                if (_messagesList.isEmpty) {
                  // on first message(add user to my_users collection of chat user)
                  Apis.sendFirstMessage(
                      widget.user, _textEditingController.text, Type.text);
                } else {
                  //simply send message
                  Apis.sendMessage(
                      widget.user, _textEditingController.text, Type.text);
                }
                _textEditingController.text = '';
              }
            },
            minWidth: 0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            shape: CircleBorder(),
            color: Colors.blueAccent,
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
