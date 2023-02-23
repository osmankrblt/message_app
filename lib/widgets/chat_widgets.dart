import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/constants/utils.dart';
import 'package:message_app/models/chat_model.dart';
import 'package:message_app/widgets/get_my_widgets.dart';
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

    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment:
          isPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: Column(
              crossAxisAlignment:
                  isPeer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                Material(
                  elevation: 10,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: isPeer
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black.withOpacity(0.4),

                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(5, 5), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      color: isPeer
                          ? Colors.white
                          : myConstants.themeColor.shade400,
                    ),
                    child: chatModel.content != ""
                        ? !chatModel.content.trim().endsWith(".gif")
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3.0,
                                  horizontal: 6.0,
                                ),
                                child: richText(
                                  chatModel.content,
                                  isPeer,
                                  TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : Container(
                                width: 150,
                                child: showImageRectangle(
                                  chatModel.content,
                                  50,
                                ),
                              )
                        : Container(),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
                  child: Text(
                    DateFormat.Hm().format(tsdate),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  buildImage(
    String media,
    double size,
    Function onTap,
  ) {
    return media != ""
        ? InkWell(
            onTap: () async {
              await onTap();
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: CachedNetworkImage(
                cacheKey: media,
                imageUrl: media,
                maxWidthDiskCache: size.toInt(),
                imageBuilder: (context, imageProvider) => Material(
                  elevation: 10,
                  color: Colors.transparent,
                  shadowColor: Colors.black,
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
