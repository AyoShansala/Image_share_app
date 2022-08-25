import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_share_app/home_screen/home_screen.dart';
import 'package:photo_share_app/search_posts/user.dart';
import 'package:photo_share_app/search_posts/users_design_widget.dart';

class SearchPost extends StatefulWidget {
  const SearchPost({Key? key}) : super(key: key);

  @override
  State<SearchPost> createState() => _SearchPostState();
}

class _SearchPostState extends State<SearchPost> {
  Future<QuerySnapshot>? postDocumentList;
  String userNameText = '';
  initSearchingpost(String textEntered) {
    postDocumentList = FirebaseFirestore.instance
        .collection("users")
        .where('name', isGreaterThanOrEqualTo: textEntered)
        .get();
    setState(() {
      postDocumentList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade300,
                Colors.pink,
              ],
            ),
          ),
        ),
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              userNameText = textEntered;
            });
            initSearchingpost(textEntered);
          },
          decoration: InputDecoration(
            hintText: "Search Post here....",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                initSearchingpost(userNameText);
              },
            ),
            prefixIcon: IconButton(
              icon: const Padding(
                padding: EdgeInsets.only(
                  right: 12.0,
                  bottom: 4.0,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => HomeScreen()));
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: postDocumentList,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Users model = Users.fromJson(snapshot.data!.docs[index]
                        .data()! as Map<String, dynamic>);
                    return UsersDesignWidget(
                      model: model,
                      context: context,
                    );
                  },
                )
              : const Center(
                  child: Text("No Record exist"),
                );
        },
      ),
    );
  }
}
