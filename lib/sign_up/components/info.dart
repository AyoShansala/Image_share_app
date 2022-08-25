import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_share_app/account_check/account_check.dart';
import 'package:photo_share_app/home_screen/home_screen.dart';
import 'package:photo_share_app/log_in/login_screen.dart';
import 'package:photo_share_app/widgets/button_square.dart';
import 'package:photo_share_app/widgets/input_field.dart';

class Credentials extends StatefulWidget {
  @override
  State<Credentials> createState() => _CredentialsState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _CredentialsState extends State<Credentials> {
  final TextEditingController _fullNameController =
      TextEditingController(text: "");
  final TextEditingController _emailTextController =
      TextEditingController(text: "");
  final TextEditingController _passTextController =
      TextEditingController(text: "");
  final TextEditingController _pohoneNumController =
      TextEditingController(text: "");

  File? imageFile;
  String? imageUrl;
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              //create showImagedialog
              _showImageDialog();
            },
            child: CircleAvatar(
              radius: 60,
              backgroundImage: imageFile == null
                  ? AssetImage("lib/images/avatar.png")
                  : Image.file(imageFile!).image,
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          InputField(
            hintText: "Enter User Name",
            icon: Icons.person,
            obscureText: false,
            textEditingController: _fullNameController,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          InputField(
            hintText: "Enter Email",
            icon: Icons.email_rounded,
            obscureText: false,
            textEditingController: _emailTextController,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          InputField(
            hintText: "Enter Password",
            icon: Icons.lock,
            obscureText: true,
            textEditingController: _passTextController,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          InputField(
            hintText: "Enter PhoneNumber",
            icon: Icons.phone,
            obscureText: false,
            textEditingController: _pohoneNumController,
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          ButtonSquare(
            text: "Create Account",
            colors1: Colors.red,
            colors2: Colors.redAccent,
            press: () async {
              if (imageFile == null) {
                Fluttertoast.showToast(msg: "Please Select an Image");
                return;
              }
              try {
                //upload image to fire storage
                final ref = FirebaseStorage.instance
                    .ref()
                    .child('userImages')
                    .child(DateTime.now().toString() + '.jpg');
                await ref.putFile(imageFile!);
                //download uploaded image url
                imageUrl = await ref.getDownloadURL();
                await _auth.createUserWithEmailAndPassword(
                  email: _emailTextController.text.trim().toLowerCase(),
                  password: _passTextController.text.trim(),
                );
                final User? user = _auth.currentUser;
                final _uid = user!.uid;
                //upload user data to firestore
                FirebaseFirestore.instance.collection('users').doc(_uid).set({
                  'id': _uid,
                  'userimage': imageUrl,
                  'name': _fullNameController.text,
                  'email': _emailTextController.text,
                  'phoneNumber': _pohoneNumController.text,
                  'createAt': Timestamp.now(),
                });
                Navigator.canPop(context) ? Navigator.pop(context) : null;
              } catch (error) {
                Fluttertoast.showToast(msg: error.toString());
              }
              //go to homepage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeScreen(),
                ),
              );
            },
          ),
          AccountCheck(
            login: false,
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
