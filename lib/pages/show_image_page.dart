import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    return Hero(
      tag: imgUrl,
      child: Scaffold(
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
          backgroundColor: Colors.black,
        ),
        body: Material(
          color: Colors.black,
          child: Center(
            child: Container(
              color: Colors.black,
              child: CachedNetworkImage(
                // maxWidthDiskCache: MediaQuery.of(context).size.width.toInt(),
                imageUrl: imgUrl,
                cacheKey: imgUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
