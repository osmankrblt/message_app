import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/models/chat_model.dart';

import '../pages/show_image_page.dart';

class message extends StatelessWidget {
  ChatModel chatModel;
  bool isPeer;

  message({
    Key? key,
    required this.chatModel,
    required this.isPeer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime tsdate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(chatModel.timestamp));

// String fdatetime = DateFormat('dd-MMM-yyy').format(tsdate);

    return Row(
      mainAxisAlignment:
          isPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
          crossAxisAlignment:
              isPeer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: myConstants.themeColor,
                ),
                color: isPeer ? Colors.white : myConstants.themeColor.shade200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildImage(chatModel.image, 250, () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageScreen(
                          userName: chatModel.idFrom,
                          imgUrl: chatModel.image,
                        ),
                      ),
                    );
                  }),
                  !chatModel.content.trim().endsWith(".gif")
                      ? chatModel.content != ""
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 6.0,
                              ),
                              child: Text(
                                chatModel.content,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : Container()
                      : buildImage(
                          chatModel.content,
                          100,
                          () {},
                        ),
                ],
              ),
            ),
            Text(
              "${tsdate.hour.toString()}:${tsdate.minute.toString()}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  buildImage(
    String media,
    double size,
    Function onTap,
  ) {
    print(media.toString());

    return media != ""
        ? InkWell(
            onTap: () async {
              await onTap();
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: size,
                height: size,
                child: CachedNetworkImage(
                  cacheKey: media,
                  imageUrl: media,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : Container();
  }
}
