import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:photo_share_app/home_screen/home_screen.dart';
import 'package:photo_share_app/widgets/button_square.dart';

class OwnerDetails extends StatefulWidget {
  String? img;
  String? userimg;
  String? name;
  DateTime? date;
  String? docId;
  String? userId;
  int? downloads;

  OwnerDetails({
    this.img,
    this.userimg,
    this.name,
    this.date,
    this.docId,
    this.userId,
    this.downloads,
  });

  @override
  State<OwnerDetails> createState() => _OwnerDetailsState();
}

class _OwnerDetailsState extends State<OwnerDetails> {
  int? total;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink,
              Colors.deepOrange.shade300,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.2, 0.9],
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Image.network(
                        widget.img!,
                        width: MediaQuery.of(context).size.width,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Owner information',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(
                          widget.userimg!,
                        ),
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Uploaded by: ' + widget.name!,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  DateFormat("dd MMMM, yyyy - hh:mm a")
                      .format(widget.date!)
                      .toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.download_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                    Text(
                      " " + widget.downloads.toString(),
                      style: const TextStyle(
                        fontSize: 28.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ButtonSquare(
                    text: 'Download',
                    colors1: Colors.green,
                    colors2: Colors.lightGreen,
                    press: () async {
                      print('button press');
                      try {
                        var imageId =
                            await ImageDownloader.downloadImage(widget.img!);
                        // if (imageId == null) {
                        //   return;
                        // }

                        Fluttertoast.showToast(msg: 'Image Svaed to gallery');
                        total = widget.downloads! + 1;

                        FirebaseFirestore.instance
                            .collection('wallpaper')
                            .doc(widget.docId)
                            .update(
                          {
                            'downloads': total,
                          },
                        ).then(
                          (value) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen()),
                            );
                          },
                        );
                      } on PlatformException catch (error) {
                        print(error);
                      }
                    },
                  ),
                ),
                FirebaseAuth.instance.currentUser!.uid == widget.userId
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: ButtonSquare(
                          text: 'Delete',
                          colors1: Colors.green,
                          colors2: Colors.lightGreen,
                          press: () {
                            FirebaseFirestore.instance
                                .collection('wallpaper')
                                .doc(widget.docId)
                                .delete()
                                .then((value) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => HomeScreen()),
                              );
                            });
                          },
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: ButtonSquare(
                    text: 'Go Back',
                    colors1: Colors.green,
                    colors2: Colors.lightGreen,
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
