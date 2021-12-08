import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sns_app/model/post.dart';
import 'package:firebase_sns_app/utils/authentication.dart';
import 'package:firebase_sns_app/utils/firestore/posts.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text(
          "新規投稿",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: contentController,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (contentController.text.isNotEmpty) {
                    Post newPost = Post(
                        content: contentController.text,
                        postAccountId: Authentication.myAccount!.id);
                    var result = await PostFirestore.addPost(newPost);
                    if (result) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text("投稿"))
          ],
        ),
      ),
    );
  }
}
