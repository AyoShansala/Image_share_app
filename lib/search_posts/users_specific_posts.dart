import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_share_app/log_in/login_screen.dart';
import 'package:photo_share_app/owner_details/owner_details.dart';
import 'package:photo_share_app/profile_screen/profile_screen.dart';
import 'package:photo_share_app/search_posts/search_post.dart';

class UserSpecificPostsScreen extends StatefulWidget {
  String? userId;
  String? userName;
  UserSpecificPostsScreen({
    Key? key,
    this.userId,
    this.userName,
  }) : super(key: key);

  @override
  State<UserSpecificPostsScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<UserSpecificPostsScreen> {
  String? myImage;
  String? myName;

  void read_userInfo() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
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
          title: Text(widget.userName!),
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
              .where('id', isEqualTo: widget.userId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
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
