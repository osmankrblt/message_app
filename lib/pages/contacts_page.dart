import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/helper/contacts_provider.dart';
import 'package:provider/provider.dart';
import 'package:message_app/constants/my_constants.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<ContactsProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            showToast(
              "Contacts updating",
            );
            await syncAllContacts();
            setState(
              () {},
            );
          },
          child: const Icon(
            Icons.refresh,
          ),
        ),
        body: cp.myFriends.isEmpty
            ? const Center(
                child: Text(
                  'You have not contacts in this app',
                ),
              )
            : SingleChildScrollView(
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: cp.myFriends.length,
                  separatorBuilder: (context, index) => Divider(
                    color: myConstants.themeColor,
                  ),
                  itemBuilder: ((context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                    height: 50,
                                    fit: BoxFit.fitHeight,
                                    imageUrl: cp.myFriends[index].profilePic,
                                    cacheKey: cp.myFriends[index].profilePic,
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      radius: 50,
                                      backgroundImage: imageProvider,
                                    ),
                                    placeholder: (context, url) => CircleAvatar(
                                      radius: 50,
                                      child: const CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                      backgroundColor: myConstants.themeColor,
                                      child: const Icon(
                                        Icons.account_circle,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cp.myFriends[index].name,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    cp.myFriends[index].bio,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              cp.myFriends[index].feel != ""
                                  ? Container(
                                      margin: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: myConstants.themeColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          cp.myFriends[index].feel,
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      )),
                ),
              ),
      ),
    );
  }

  syncAllContacts() async {
    bool result = await checkInternetStatus();
    if (result == true) {
      final cp = Provider.of<ContactsProvider>(context, listen: false);
      await cp.syncAllContacts();
    } else {
      showToast('No internet :(');
    }
  }
}
