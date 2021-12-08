import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sns_app/model/account.dart';
import 'package:firebase_sns_app/model/post.dart';
import 'package:firebase_sns_app/utils/firestore/posts.dart';
import 'package:firebase_sns_app/utils/firestore/users.dart';
import 'package:firebase_sns_app/view/time_line/post_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text(
          "タイムライン",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
//'posts'コレクションにドキュメントが追加されるたびにbuilderが処理を開始する
          stream: PostFirestore.posts
              //作成日時が早いもの順に表示
              .orderBy('created_time', descending: true)
              .snapshots(),
          builder: (context, postSnapshot) {
            if (postSnapshot.hasData) {
              //投稿したユーザーを取得
              List<String> postAccountIds = [];
              //投稿の数だけForEachを回す
              postSnapshot.data!.docs.forEach((doc) {
                //Map型に変換 （メリット：　同時に複数の型の値を格納できる）
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                //投稿したユーザーの情報がリスト(postAccountIds)に格納されていない場合
                if (!postAccountIds.contains(data['post_account_id'])) {
                  //投稿したユーザーの情報をリストに追加
                  postAccountIds.add(data['post_account_id']);
                }
              });
              //FutureBuilder<ここは、getPostUserMapから返す値>
              return FutureBuilder<Map<String, Account>?>(
                  future: UserFirestore.getPostUserMap(postAccountIds),
                  builder: (context, userSnapshot) {
                    //情報の取得が完了した場合
                    if (userSnapshot.hasData &&
                        userSnapshot.connectionState == ConnectionState.done) {
                      return ListView.builder(
                          //投稿の数だけ
                          itemCount: postSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                                postSnapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            //インスタンス化
                            Post post = Post(
                                content: data['content'],
                                postAccountId: data['post_account_id'],
                                createdTime: data['created_time']);
                            //ユーザー情報
                            Account postAccount =
                                userSnapshot.data![post.postAccountId]!;
                            return Container(
                              decoration: BoxDecoration(
                                  border: index == 0
                                      //１番目の投稿の場合
                                      ? Border(
                                          top: BorderSide(
                                              color: Colors.grey, width: 0),
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 0),
                                        )
                                      : Border(
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 0),
                                        )),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    foregroundImage:
                                        NetworkImage(postAccount.imagePath),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    postAccount.name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '@${postAccount.userId}',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              Text(DateFormat("M/d/yy").format(
                                                  post.createdTime!.toDate())),
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
    );
  }
}
