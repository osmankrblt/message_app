import 'package:flutter/material.dart';
import '../widgets/get_my_widgets.dart';

class ImageScreen extends StatelessWidget {
  late String imgUrl;
  late String userName;

  ImageScreen({
    Key? key,
    required this.imgUrl,
    required this.userName,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.download,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.black,
      ),
      body: Material(
        color: Colors.black,
        child: Center(
          child: Container(
            color: Colors.black,
            child: showImageRectangle(
              imgUrl,
              500,
            ),
          ),
        ),
      ),
    );
  }
}
