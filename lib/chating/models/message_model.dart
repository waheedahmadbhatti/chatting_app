class MessageModel {
  final String toId;
  final String msg;
  final String read;
  final Type type;
  final String send;
  final String fromId;

  MessageModel({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.send,
    required this.fromId,
  });

  // Factory method to create a MessageModel instance from a JSON map
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      toId: json['toId'] ?? "",
      msg: json['msg'] ?? "",
      read: json['read'] ?? "",
      type:  json['type'] ==Type.image.name ? Type.image:Type.text,
      send: json['send'] ?? "",
      fromId: json['fromId'] ?? "",
    );
  }

  // Convert MessageModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'toId': toId,
      'msg': msg,
      'read': read,
      'type': type.name,
      'send': send,
      'fromId': fromId,
    };
  }
}
enum Type{ text,image}
