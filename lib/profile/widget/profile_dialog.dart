import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user_model.dart';
import 'package:my_chat/profile/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
final ChatUserModel user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
    content: SizedBox(width: mq.width*.6,
    height: mq.height*.35,
    child: Stack(
      children: [
        Positioned(
          top: mq.height*.075,
          left: mq.width*.09,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*.25),
            child: CachedNetworkImage(
                width: mq.width *.5,
                fit: BoxFit.cover,
                imageUrl: user.image,
            errorWidget: (context , url,error)=>CircleAvatar(child: Icon(Icons.person),),),
          ),
        ),
        Positioned(
            left: mq.width*.04,
            top: mq.height*.02,
            width: mq.width*.55,
            child: Text(user.name)),
        Positioned(
          right: 8,
          top: 6,
          child: Align(
            alignment: Alignment.topRight,
            child: MaterialButton(onPressed: (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: user)));
            },minWidth: 0,
            padding: EdgeInsets.all(0),
            shape: CircleBorder(),
            child: Icon(Icons.info_outline),),
          ),
        )

      ],
    ),
    ),
    );
  }
}
