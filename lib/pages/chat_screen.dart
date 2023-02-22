import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:message_app/constants/my_constants.dart';
import 'package:message_app/helper/chat_provider.dart';
import 'package:message_app/widgets/get_my_widgets.dart';
import 'package:provider/provider.dart';

import '../constants/utils.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  late String currentUserId;
  late UserModel peerUser;
  late String groupChatId;

  ChatScreen({
    required String currentUserId,
    required UserModel peerUser,
  }) {
    this.currentUserId = currentUserId;
    this.peerUser = peerUser;
    this.groupChatId = getGroupChatId(
      currentId: currentUserId,
      peerId: peerUser.uid,
    );
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<QueryDocumentSnapshot> listMessage = [];

  int _limit = 20;
  int _limitIncrement = 20;
  late int sWidth;
  File? imageFile = null;
  File? uploadFile = null;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    // chatProvider = context.read<ChatProvider>();

    listScrollController.addListener(_scrollListener);
    // readLocal();
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });

      print("Limit $_limit");
    }
  }

  @override
  Widget build(BuildContext context) {
    sWidth = MediaQuery.of(context).size.width.toInt();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              showImageCircle(
                widget.peerUser.profilePic,
                150,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  widget.peerUser.name,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: myConstants.themeColor,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/chats_bakcground.jpg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    buildListMessage(),
                    buildInput(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Hide sticker or back
  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }

  void onSendMessage(String content, File? image) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (content.trim() != '' || imageFile != null) {
      textEditingController.clear();
      chatProvider.sendChatMessage(content, image, uploadFile,
          widget.groupChatId, widget.currentUserId, widget.peerUser.uid);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);

      setState(() {
        imageFile = null;
      });
    } else {
      showToast('Nothing to send');
    }
  }

  buildListMessage() {
    final messages = Provider.of<ChatProvider>(context, listen: true);
    String date = "";
    return Flexible(
      child: widget.groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: messages.getChatMessage(widget.groupChatId, _limit),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(myConstants.themeColor),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error"),
                  );
                } else {
                  listMessage = snapshot.data!.docs;

                  return ListView.separated(
                    padding: EdgeInsets.all(10.0),
                    separatorBuilder: (context, index) {
                      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(ChatModel.fromDoc(
                          listMessage[index],
                        ).timestamp),
                      );

                      print(date);
                      print(DateFormat("d/MM/y").format(tsdate));

                      print(date != DateFormat("d/MM/y").format(tsdate));
                      return date != DateFormat("d/MM/y").format(tsdate)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: myConstants.themeColor.shade100,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      date,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container();
                    },
                    itemBuilder: (context, index) {
                      ChatModel message = ChatModel.fromDoc(
                        listMessage[index],
                      );

                      DateTime tsdate = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(message.timestamp),
                      );
                      date = DateFormat("d/MM/y").format(tsdate);

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: buildItem(
                          index,
                          message,
                        ),
                      );
                    },
                    itemCount: listMessage.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                color: myConstants.themeColor,
              ),
            ),
    );
  }

  buildItem(int index, ChatModel chatModel) {
    return message(
      chatModel: chatModel,
      isPeer: chatModel.idFrom == widget.currentUserId ? false : true,
    );
  }

  showSelectedMedia() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  imageFile = null;
                  setState(() {});
                },
                icon: Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
              ),
            ),
            Image.file(
              imageFile!,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  buildInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          15,
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          imageFile != null ? showSelectedMedia() : Container(),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  imageFile = await pickImage();
                  setState(() {});
                },
                icon: Icon(
                  Icons.file_upload_outlined,
                  color: myConstants.themeColor,
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(
                    8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: myConstants.themeColor,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                    color: Colors.white,
                  ),
                  child: TextField(
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    focusNode: focusNode,
                    autofocus: false,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLines: null,
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (value) {
                      // onSendMessage(textEditingController.text, imageFile);
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  bool result = await checkInternetStatus();
                  if (result) {
                    onSendMessage(textEditingController.text, imageFile);
                  } else {
                    showToast("No internet.Your messages cant sent");
                  }
                },
                icon: Icon(
                  Icons.send,
                  color: myConstants.themeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
