import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_share_app/home_screen/home_screen.dart';
import 'package:photo_share_app/log_in/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name = '';
  String? email = '';
  String? image = '';
  String? phoneNo = '';

  File? imageXFile;
  String? userNameInput = '';
  String? userImageUrl;

  //getting relevent data from firebase database
  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!['name'];
          email = snapshot.data()!['email'];
          image = snapshot.data()!['userimage'];
          phoneNo = snapshot.data()!['phoneNumber'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDataFromDatabase();
  }

  //.....dilaog box for select image selection source type................
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
        imageXFile = File(croppedImage.path);
        _updateImageInFirestore();
      });
    }
  }

  //upadate user data................................................
  Future _updateUserName() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': userNameInput,
    });
  }

  //dialog box for enter your name again to change.....................
  _displayTextinputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Your Name Here'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                userNameInput = value;
              });
            },
            decoration: InputDecoration(hintText: "Type Here"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(
                  () {
                    _updateUserName();
                    updateProfileNameOnUserExistingPosts();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(),
                      ),
                    );
                  },
                );
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.amber,
              ),
            )
          ],
        );
      },
    );
  }

  //firestore and firestorage data upadte....................................................
  void _updateImageInFirestore() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    fStorage.Reference reference = fStorage.FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child(fileName);
    fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
    fStorage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => {});
    await taskSnapshot.ref.getDownloadURL().then((url) async {
      userImageUrl = url;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'userimage': userImageUrl,
    }).whenComplete(() {
      updateProfileImageOnUserExistingPosts();
    });
  }

  //updat profile image on user existing posts..........................
  //without this method allt he other posts user images and other informations will not update.....
  updateProfileImageOnUserExistingPosts() async {
    await FirebaseFirestore.instance
        .collection('wallpaper')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      (snapshot) {
        for (int index = 0; index < snapshot.docs.length; index++) {
          String userProfileImageInPost = snapshot.docs[index]['userImage'];
          if (userProfileImageInPost != userImageUrl) {
            FirebaseFirestore.instance
                .collection('wallpaper')
                .doc(snapshot.docs[index].id)
                .update({
              'userImage': userImageUrl,
            });
          }
        }
      },
    );
  }

  //updat profile name on user existing posts..........................
  //without this method all the other posts user name and other informations will not updat
  updateProfileNameOnUserExistingPosts() async {
    await FirebaseFirestore.instance
        .collection('wallpaper')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      (snapshot) {
        for (int index = 0; index < snapshot.docs.length; index++) {
          String userProfileNameInPost = snapshot.docs[index]['name'];
          if (userProfileNameInPost != userNameInput) {
            FirebaseFirestore.instance
                .collection('wallpaper')
                .doc(snapshot.docs[index].id)
                .update({
              'name': userNameInput,
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
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
        ),
        centerTitle: true,
        backgroundColor: Colors.pink.shade400,
        title: const Center(
          child: Text("Profile Screen"),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                //_show Image dialog
                _showImageDialog();
              },
              child: CircleAvatar(
                backgroundColor: Colors.amber,
                minRadius: 52,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imageXFile == null
                      ? NetworkImage(image!)
                      : Image.file(imageXFile!).image,
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Name : " + name!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    //_display text input dialog
                    _displayTextinputDialog(context);
                  },
                  icon: const Icon(
                    Icons.edit,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "Email : " + email!,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "Phone Number : " + phoneNo!,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(),
                  ),
                );
              },
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(
                primary: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
