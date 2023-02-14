import 'package:flutter/material.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/helper/contacts_provider.dart';
import 'package:message_app/pages/quick_user_info.dart';
import 'package:provider/provider.dart';
import 'package:message_app/constants/my_constants.dart';
import '../models/user_model.dart';
import '../widgets/get_my_widgets.dart';

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
        appBar: AppBar(
          title: Text("Friends"),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: myConstants.themeColor,
                size: 30,
              )),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            showToast(
              "Contacts updating",
            );
            await syncAllContacts();
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
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: cp.myFriends.length,
                  itemBuilder: ((context, index) => userListTile(
                        cp.myFriends[index],
                      )),
                ),
              ),
      ),
    );
  }

  Widget userListTile(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: false,
                      enableDrag: true,
                      context: context,
                      builder: (context) => QuickInfo(user: user),
                      backgroundColor: Colors.transparent,
                    );
                  },
                  child: showImageCircle(
                    user.profilePic,
                    140,
                  ),
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
                  user.name,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  width: 230.0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.bio,
                          maxLines: 2,
                          // softWrap: false,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            user.feel != ""
                ? Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: myConstants.themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        user.feel,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
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
