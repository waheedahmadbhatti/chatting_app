class ChatUserModel {
  late String id;
  late  String name;
  late  String about;
  late String createdAt;
  late String lastActive;
  late bool isOnline;
  late String email;
  late String image; // Assuming the image field is a URL or path to the image
  late String pushToken;

  ChatUserModel({
    required this.id,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.lastActive,
    required this.isOnline,
    required this.email,
    required this.image,
    required this.pushToken,
  });

  // Factory method to create ChatUserModel from a json (e.g., from Firestore)
  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      about: json['about'] ?? '',
      createdAt: json['created_at'] ?? '',
      lastActive: json['last_active'] ?? '',
      isOnline: json['is_online'] ?? false,
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      pushToken: json['push_token'] ?? '',
    );
  }

  // Method to convert ChatUserModel to a json (e.g., for Firestore updates)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'about': about,
      'created_at': createdAt,
      'last_active': lastActive,
      'is_online': isOnline,
      'email': email,
      'image': image,
      'push_token': pushToken,
    };
  }
}
