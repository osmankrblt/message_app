import 'package:flutter/material.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/helper/contacts_provider.dart';
import 'package:provider/provider.dart';
import 'package:message_app/constants/my_constants.dart';
import '../models/user_model.dart';
import '../widgets/get_my_widgets.dart';
import 'show_image_page.dart';

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageScreen(
                            userName: user.name, imgUrl: user.profilePic),
                      ),
                    );
                  },
                  child: showImage(
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
                Text(
                  user.bio,
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
