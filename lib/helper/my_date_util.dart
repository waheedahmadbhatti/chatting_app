import 'package:flutter/material.dart';

class MyDateUtil {
  // for getting formated time from millisecondSinceEpoch string
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

//for getting formatted time for send & read
  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime send = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    final formattedTime = TimeOfDay.fromDateTime(send).format(context);
    if (now.day == send.day &&
        now.month == send.month &&
        now.year == send.year) {
      return formattedTime;
    }
    return now.year == send.year
        ? '$formattedTime  -  ${send.day}  ${getMonth(send)}  ${send.year}'
        : '$formattedTime  -  ${send.day}  ${getMonth(send)}  ${send.year}';
  }

  //get last message time from month no. or index
  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return showYear
        ? '${sent.day} ${getMonth(sent)} ${sent.year}'
        : '${sent.day} ${getMonth(sent)}';
  }

  //get formatted last active time of user in chat screen
  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;
    // if time is not available then return below statement
    if (i == -1) return 'last seen not available';
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();
    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'last seen today at $formattedTime';
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'last seen yesterday at $formattedTime';
    }
    String month = getMonth(time);
    return 'last seen on ${time.day} $month on $formattedTime';
  }

  // get month name from month no. or index
  static String getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
