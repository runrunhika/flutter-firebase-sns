/* 投稿に関するデータの管理 */

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id; //投稿のID
  String content; //投稿内容
  String postAccountId; //投稿したユーザーのID
  Timestamp? createdTime;

  Post(
      {this.id = '',
      required this.content,
      required this.postAccountId,
      this.createdTime});
}
