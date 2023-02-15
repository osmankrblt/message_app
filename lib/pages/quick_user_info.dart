import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/pages/show_image_page.dart';
import 'package:message_app/widgets/get_my_widgets.dart';
import '../models/user_model.dart';

class QuickInfo extends StatelessWidget {
  UserModel user;

  QuickInfo({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 75,
        vertical: MediaQuery.of(context).size.height * 0.3.toInt(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: InkWell(
              onTap: () async {
                user.profilePic != ""
                    ? await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(
                              userName: user.name, imgUrl: user.profilePic),
                        ),
                      )
                    : showToast("No image");
              },
              child: showImageRectangle(
                user.profilePic,
                360,
              ),
            ),
          ),
          Divider(color: Colors.transparent),
          Container(
            width: double.infinity,
            color: myConstants.themeColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.call,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.message,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.video_call_outlined,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
