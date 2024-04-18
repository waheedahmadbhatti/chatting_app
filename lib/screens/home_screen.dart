import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chat/api/api.dart';
import 'package:my_chat/helper/dialog.dart';
import 'package:my_chat/main.dart';
import 'package:my_chat/models/chat_user_model.dart';
import 'package:my_chat/profile/profile_screen.dart';
import 'package:my_chat/screens/call/call_page.dart';
import 'package:my_chat/screens/widget/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUserModel> _chatList = [];
  // for storing searched items
  final List<ChatUserModel> _searchList = [];
  // for storing search status
  bool _isSearching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Apis.getSelfInfo();

    //for updating user status sccording t lifecycle events
    //resume == active or online
    //pause == inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Active or not active $message');
      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          Apis.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          Apis.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Name,Email, ...'),
                    autofocus: true,
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();
                      for (var i in _chatList) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text(
                    "Personal Chat",
                  ),
            leading: Icon(Icons.home),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                      _isSearching ? Icons.cancel_outlined : Icons.search)),

              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: Apis.me,
                                )));
                  },
                  icon: Icon(Icons.more_vert)),
            ],
          ),
          body: StreamBuilder(
              stream: Apis.getMyUsersId(),
              builder: (context, snapshot) {
                print("myUsers ${snapshot.data?.docs}");
                return StreamBuilder(
                    stream: Apis.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _chatList = data!
                              .map((e) => ChatUserModel.fromJson(e.data()))
                              .toList();
                          return _chatList.isEmpty
                              ? Center(
                                  child: Text("Please Add New User"),
                                )
                              : ListView.builder(
                                  itemCount: _isSearching
                                      ? _searchList.length
                                      : _chatList.length,
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _chatList[index],
                                    );
                                  });
                      }
                    });
              }),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: FloatingActionButton(
              onPressed: () async {
                // await Apis.auth.signOut();
                // await GoogleSignIn().signOut();
                _addChatUserDialog();
              },
              child: Icon(Icons.add_comment_outlined),
            ),
          ),
        ),
      ),
    );
  }

  // dialog for Adding user
  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Row(
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    color: Colors.blue,
                  ),
                  Text(" Add User"),
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (val) => email = val,
                decoration: InputDecoration(
                    hintText: 'Enter Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.blue,
                    ),
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
                  onPressed: () async {
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await Apis.addChatUser(email).then((value) => {
                            if (!value)
                              {
                                Dialogs.showSnackbar(
                                    context, 'User does not Exists!')
                              }
                          });
                    }
                  },
                  child: Text('Add'),
                )
              ],
            ));
  }
}
