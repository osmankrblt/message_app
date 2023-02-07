import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../helper/firebase_provider.dart';

class ContactsPage extends StatefulWidget {
  ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    final myFriends =
        Provider.of<FirebaseProvider>(context, listen: true).myFriends;

    var myConstants;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              showToast("Kişileriniz güncelleniyor");
              await getAllContacts(context);
            },
            child: Icon(
              Icons.refresh,
            )),
        body: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: myFriends.length,
            itemBuilder: ((context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            height: 50,
                            fit: BoxFit.fill,
                            imageUrl: myFriends[index].profilePic,
                            cacheKey: myFriends[index].profilePic,
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 50,
                              backgroundImage: imageProvider,
                            ),
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(
                              backgroundColor: myConstants.themeColor,
                              child: const Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                        Text(myFriends[index].name),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  getAllContacts(BuildContext context) async {
    final ap = Provider.of<FirebaseProvider>(context, listen: false);
    await ap.getAllContacts();
    setState(() {});
  }
}
