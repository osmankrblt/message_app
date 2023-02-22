import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:provider/provider.dart';

import '../helper/chat_provider.dart';
import '../models/user_model.dart';
import '../pages/quick_user_info.dart';

AppBar getAppbar(title) {
  return AppBar(
    automaticallyImplyLeading: true,
    foregroundColor: myConstants.themeColor,
    title: Text(
      title,
      style: TextStyle(
        color: myConstants.appBarTitleColor,
      ),
    ),
    backgroundColor: myConstants.appBarBackgroundColor,
  );
}

Widget showImageCircle(String imgUrl, int maxWidthForCache) {
  return imgUrl != ""
      ? CachedNetworkImage(
          maxWidthDiskCache: maxWidthForCache,
          fit: BoxFit.cover,
          imageUrl: imgUrl,
          cacheKey: imgUrl,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            backgroundImage: imageProvider,
          ),
          placeholder: (context, url) => const CircularProgressIndicator(),
        )
      : CircleAvatar(
          backgroundColor: myConstants.themeColor,
          child: const Icon(
            Icons.account_circle,
            color: Colors.white,
            size: 25,
          ),
        );
}

Widget showImageRectangle(String imgUrl, int maxWidthForCache) {
  return Hero(
    tag: imgUrl,
    child: imgUrl != ""
        ? CachedNetworkImage(
            maxWidthDiskCache: maxWidthForCache,
            fit: BoxFit.contain,
            imageUrl: imgUrl,
            cacheKey: imgUrl,
          )
        : Container(
            width: 480,
            height: 250,
            decoration: BoxDecoration(
              color: myConstants.themeColor,
              shape: BoxShape.rectangle,
            ),
            child: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 100,
            ),
          ),
  );
}

messageUsers(BuildContext context, UserModel user, String groupChatId) {
  final chatProvider = Provider.of<ChatProvider>(context, listen: true);

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
            width: 10,
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
                width: MediaQuery.of(context).size.width * 0.55,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "---------",
                        maxLines: 2,
                        // softWrap: false,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
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
          Text(
            "1505",
          ),
        ],
      ),
    ),
  );
}
