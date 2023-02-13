import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';

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

Widget showImage(String imgUrl, int maxWidthForCache) {
  return Hero(
    tag: imgUrl,
    child: imgUrl != ""
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
              size: 50,
            ),
          ),
  );
}
