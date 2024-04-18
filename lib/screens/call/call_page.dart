import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
   CallPage({Key? key, required this.userId,required this.userName}) : super(key: key);
  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    String callId = generateUniqueId();
print("caller id is == $callId");
print("user Id is == ${userId.toString()}");
    return ZegoUIKitPrebuiltCall(
      appID: 1002212876, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: "f857e6219e16759746402cbb710ef0a956b80d38142f61f00f44b46d6aedb152", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: userId,
      userName: userName,
      callID: callId,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),

    );
  }

}
String generateUniqueId() {
  var uuid = Uuid();
  return uuid.v4(); // Generate a Version 4 (random) UUID
}

