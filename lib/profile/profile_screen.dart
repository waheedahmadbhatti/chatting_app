import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/auth/screen/login.dart';
import 'package:my_chat/helper/dialog.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  String? _image = null;

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
            "Profile",
          ),
        ),
        body: Form(
          key: formKey,
          child: Padding(
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
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .3),
                              child: Image.file(
                                File(_image!),
                                height: mq.height * .1,
                                width: mq.height * .1,
                                fit: BoxFit.cover,
                              ),
                              //image from server
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .3),
                              child: CachedNetworkImage(
                                height: mq.height * .1,
                                width: mq.height * .1,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(child: Icon(Icons.person)),
                              ),
                            ),
                      Positioned(
                        left: 30,
                        bottom: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child: Icon(Icons.edit),
                          shape: CircleBorder(),
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  Text(widget.user.email),
                  SizedBox(
                    height: mq.height * .08,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => Apis.me.name = val ?? '',
                    validator: (val) => val != null ? null : 'Requires Field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: 'XYZ',
                      label: Text("Name"),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => Apis.me.about = val ?? '',
                    validator: (val) => val != null ? null : 'Requires Field',
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: 'feeling Happy',
                      label: Text("About"),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .08,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Apis.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile Updated Successfully');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Update"),
                  ),
                  SizedBox(
                    height: mq.height * .08,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // for showing progress dialog

              Dialogs.showProgressBar(context);
              await Apis.updateActiveStatus(false);
// sign out from app
              await Apis.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for hiding progress dialog
                  Navigator.pop(context);
                  //for moving to home screen
                  Navigator.pop(context);
                  Apis.auth = FirebaseAuth.instance;
                  //replacing home screen with login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });
            },
            icon: Icon(Icons.logout),
            label: Text("Logout"),
          ),
        ),
      ),
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .07),
            children: [
              Text('Pick Profile Picture', textAlign: TextAlign.center),
              SizedBox(
                height: mq.height * .04,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfilePicture(File(_image!));

                          Navigator.pop(context);
                        }
                      },
                      child: Icon(
                        Icons.photo,
                        color: Colors.green,
                      )),
                  // pick from camera
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.green,
                      ))
                ],
              )
            ],
          );
        });
  }
}
