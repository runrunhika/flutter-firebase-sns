import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sns_app/model/post.dart';
import 'package:firebase_sns_app/utils/firestore/firebase.dart';
import 'package:firebase_sns_app/utils/firestore/posts.dart';
import 'package:firebase_sns_app/utils/firestore/users.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersAccountPage extends StatefulWidget {
  final String id;
  final String name; //ユーザーネーム
  final String imagePath; //プロフィール画像
  final String selfIntroduction; //プロフィール詳細
  final String userId; //ユーザーID(ユーザーに見える)

  const UsersAccountPage({
    Key? key,
    required this.id,
    required this.name,
    required this.imagePath,
    required this.selfIntroduction,
    required this.userId,
  }) : super(key: key);

  @override
  _UsersAccountPageState createState() => _UsersAccountPageState();
}

class _UsersAccountPageState extends State<UsersAccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            //画面いっぱいの高さ
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 15, left: 15, top: 20),
                  height: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                foregroundImage: NetworkImage(widget.imagePath),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '@${widget.userId}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // IconButton(
                          //     onPressed: () {
                          //       print('chat');
                          //       Firestore.addFireStoreRoom(widget.id);
                          //     },
                          //     icon: Icon(Icons.chat_outlined))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(widget.selfIntroduction)
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.blue, width: 3))),
                  child: Text(
                    "投稿",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: UserFirestore.users
                          .doc(widget.id)
                          .collection('my_posts')
                          //作成日時が早いもの順に表示
                          .orderBy('created_time', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        //データを持っていたら
                        if (snapshot.hasData) {
                          //'my_posts'に入っているデータの数だけリストを作成
                          List<String> myPostIds = List.generate(
                              snapshot.data!.docs.length, (index) {
                            //idを取得
                            return snapshot.data!.docs[index].id;
                          });
                          return FutureBuilder<List<Post>?>(
                              //取得したidを元にPost（投稿）を作成
                              future: PostFirestore.getPostsFromIds(myPostIds),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        //投稿内容を取得
                                        Post post = snapshot.data![index];
                                        return Container(
                                          decoration: BoxDecoration(
                                              border: index == 0
                                                  //１番目の投稿の場合
                                                  ? Border(
                                                      top: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0),
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0),
                                                    )
                                                  : Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0),
                                                    )),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 22,
                                                foregroundImage: NetworkImage(
                                                    widget.imagePath),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                widget.name,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                '@${widget.userId}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ],
                                                          ),
                                                          //toDate() = Timestamp型をDateTime型に変換
                                                          Text(DateFormat(
                                                                  "M/d/yy")
                                                              .format(post
                                                                  .createdTime!
                                                                  .toDate())),
                                                        ],
                                                      ),
                                                      Text(post.content)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      });
                                } else {
                                  return Container();
                                }
                              });
                        } else {
                          return Container();
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
