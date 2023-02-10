import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:message_app/models/chat_model.dart';

myMessage(ChatModel chatModel) {
  return Column(
    children: [
      chatModel.image != ""
          ? CachedNetworkImage(
              cacheKey: chatModel.image,
              imageUrl: chatModel.image,
            )
          : Container(),
      Text(
        chatModel.content,
      ),
    ],
  );
}
