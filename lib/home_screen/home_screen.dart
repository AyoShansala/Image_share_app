import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photo_share_app/log_in/login_screen.dart';
import 'package:photo_share_app/owner_details/owner_details.dart';
import 'package:photo_share_app/profile_screen/profile_screen.dart';
import 'package:photo_share_app/search_posts/search_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String changeTitle = 'Grid View';
  bool checkView = false;
  File? imageFile;
  String? imageUrl;
  String? myImage;
  String? myName;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //......Image uploading source slection...(camera or gallery)........
  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Please choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  //get from camera
                  _getFromCamera();
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.camera,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      "Camera",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  //get from gallery
                  _getFromGallery();
                },
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.image,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      "Gallery",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  //get image from camera
  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  //get image from gallery
  void _getFromGallery() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  //crop the selected image
  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  //uploading selected images to firbase storage
  void _upload_image() async {
    if (imageFile == null) {
      Fluttertoast.showToast(msg: "Please Select an image");
      return;
    }
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('userImages')
          .child(DateTime.now().toString() + 'jpg');
      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection("wallpaper")
          .doc(DateTime.now().toString())
          .set({
        'id': _auth.currentUser!.uid,
        'userImage': myImage,
        'name': myName,
        'email': _auth.currentUser!.email,
        'Image': imageUrl,
        'downloads': 0,
        'createdAt': DateTime.now(),
      });
      Navigator.canPop(context) ? Navigator.pop(context) : null;
      imageFile = null;
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  void read_userInfo() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then<dynamic>(
      (DocumentSnapshot snapshot) async {
        myImage = snapshot.get('userimage');
        myName = snapshot.get('name');
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    read_userInfo();
  }

  //list view and grid view for display uploaded images

  Widget listViewWidget(String docid, String img, String userImg, String name,
      DateTime dateTime, String userId, int downloads) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        elevation: 15.0,
        shadowColor: Colors.white10,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink,
                Colors.deepOrange.shade300,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [
                0.2,
                0.9,
              ],
            ),
          ),
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  //create owner details
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OwnerDetails(
                        img: img,
                        userimg: userImg,
                        name: name,
                        date: dateTime,
                        docId: docid,
                        userId: userId,
                        downloads: downloads,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  img,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(userImg),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          DateFormat("dd MMMM, yyyy - hh:mm a")
                              .format(dateTime)
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //grid view
  Widget gridViewWidget(String docid, String img, String userImg, String name,
      DateTime dateTime, String userId, int downloads) {
    return GridView.count(
      primary: false,
      padding: EdgeInsets.all(6.0),
      crossAxisSpacing: 1,
      crossAxisCount: 1,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink,
                Colors.deepOrange.shade300,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [
                0.2,
                0.9,
              ],
            ),
          ),
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              //create owner details
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OwnerDetails(
                    img: img,
                    userimg: userImg,
                    name: name,
                    date: dateTime,
                    docId: docid,
                    userId: userId,
                    downloads: downloads,
                  ),
                ),
              );
            },
            child: Center(
              child: Image.network(
                img,
                fit: BoxFit.fill,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink,
            Colors.deepOrange.shade300,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [
            0.2,
            0.9,
          ],
        ),
      ),
      child: Scaffold(
        floatingActionButton: Wrap(
          direction: Axis.horizontal,
          children: [
            Container(
              margin: const EdgeInsets.all(10.0),
              child: FloatingActionButton(
                heroTag: "1",
                backgroundColor: Colors.deepOrange.shade400,
                onPressed: () {
                  //show image dialog
                  _showImageDialog();
                },
                child: const Icon(Icons.camera_enhance),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: FloatingActionButton(
                heroTag: "2",
                backgroundColor: Colors.pink.shade400,
                onPressed: () {
                  //uploading selected image
                  _upload_image();
                },
                child: const Icon(Icons.cloud_upload),
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.shade300,
                  Colors.pink,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [
                  0.2,
                  0.9,
                ],
              ),
            ),
          ),
          title: GestureDetector(
            onTap: () {
              setState(() {
                changeTitle = "List View";
                checkView = true;
              });
            },
            onDoubleTap: () {
              setState(() {
                changeTitle = "Grid View";
                checkView = false;
              });
            },
            child: Text(changeTitle),
          ),
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ),
              );
            },
            child: const Icon(
              Icons.login_outlined,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPost(),
                  ),
                );
              },
              icon: const Icon(Icons.person_search),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('wallpaper')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                if (checkView == true) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return listViewWidget(
                        snapshot.data!.docs[index].id,
                        snapshot.data!.docs[index]['Image'],
                        snapshot.data!.docs[index]['userImage'],
                        snapshot.data!.docs[index]['name'],
                        snapshot.data!.docs[index]['createdAt'].toDate(),
                        snapshot.data!.docs[index]['id'],
                        snapshot.data!.docs[index]['downloads'],
                      );
                    },
                  );
                } else {
                  return GridView.builder(
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return gridViewWidget(
                        snapshot.data!.docs[index].id,
                        snapshot.data!.docs[index]['Image'],
                        snapshot.data!.docs[index]['userImage'],
                        snapshot.data!.docs[index]['name'],
                        snapshot.data!.docs[index]['createdAt'].toDate(),
                        snapshot.data!.docs[index]['id'],
                        snapshot.data!.docs[index]['downloads'],
                      );
                    },
                  );
                }
              } else {
                return const Center(
                  child: Text(
                    "There is no tasks",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}
