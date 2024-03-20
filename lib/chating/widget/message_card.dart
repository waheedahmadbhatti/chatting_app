import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/chating/models/message_model.dart';
import 'package:my_chat/helper/dialog.dart';
import 'package:my_chat/helper/my_date_util.dart';
import 'package:my_chat/main.dart';

class MessageCard extends StatefulWidget {
  MessageModel message;
  MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        FocusScope.of(context).unfocus();
        _showBottomSheet(isMe);
      },
      child: isMe ? _ourMessage() : _senderMessage(),
    );
  }

  // sender Message
  Widget _senderMessage() {
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .03
                  : mq.width * .04),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              decoration: BoxDecoration(
                  color: const Color(0xB3D4DAEC),
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
              child: widget.message.type == Type.text
                  ? Text(widget.message.msg)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .02),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    )),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(MyDateUtil.getFormattedTime(
              context: context, time: widget.message.send)),
        )
      ],
    );
  }

  // our message
  Widget _ourMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blueAccent,
              ),
            if (widget.message.read.isEmpty)
            const Icon(
              Icons.done_all_rounded,
              color: Colors.grey,
            ),
            Text(" ${MyDateUtil.getFormattedTime(
                context: context, time: widget.message.send)}"),
          ],
        ),
        //message content
        Flexible(
          child: Container(
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .03
                  : mq.width * .04),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .04, vertical: mq.height * .01),
              decoration: BoxDecoration(
                  color: const Color(0xCCD9E0DA),
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))),
              child: widget.message.type == Type.text
                  ? Text(widget.message.msg)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .02),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    )),
        ),
      ],
    );
  }

  //bottom sheet for modifying message details
  void _showBottomSheet(bool isme) {
    // final String messageTime = MyDateUtil.getMessageTime(
    //   context: context,
    //   time: widget.message.send,
    // );
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)),
              ),
              // edit text or save image
              widget.message.type == Type.text
                  ? OptionItem(
                      icon: const Icon(
                        Icons.copy_all_outlined,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        print("llllllll");
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  : OptionItem(
                      icon: const Icon(
                        Icons.download_outlined,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        await GallerySaver.saveImage(widget.message.msg)
                            .then((success) {
                          Navigator.pop(context);
                          if (success != null) {
                            Dialogs.showSnackbar(
                                context, 'Image saved successfully');
                            print("mmmmmmmm");
                          }
                        });
                      }),
              //
              if (widget.message.type == Type.text && isme)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
              //
              //only our message are editable
              if (widget.message.type == Type.text && isme)
                OptionItem(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessageUpdateDialog();
                    }),
              //
              if (widget.message.type == Type.text && isme)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
              // only our message are deletable
              if (isme)
                OptionItem(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: 'Delete Message',
                    onTap: () {
                      Apis.deleteMessage(widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name:
                      'Send At:     ${MyDateUtil.getMessageTime(context: context, time: widget.message.send)}',
                  onTap: () {}),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.green,
                    size: 26,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read At:     Not seen yet'
                      : 'Read At:     ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  // dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Colors.blue,
                  ),
                  Text("Update Message"),
                ],
              ),
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (val)=>updatedMsg=val,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                )),
              ),
              actions: [
                // cancel button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                // update button
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Apis.updateMessage(widget.message, updatedMsg);
                  },
                  child: Text('Update'),
                )
              ],
            ));
  }
}

// custom option card (for  copy,sdit,delete,etc)
class OptionItem extends StatelessWidget {
  const OptionItem(
      {required this.icon, required this.name, required this.onTap});
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [icon, Text('    $name')],
        ),
      ),
    );
  }
}
