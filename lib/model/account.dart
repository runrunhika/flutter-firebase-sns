/* ユーザーのアカウントに関するデータの管理 */

import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String id; //ユーザーID(ユーザーに見えない)
  String name; //ユーザーネーム
  String imagePath; //プロフィール画像
  String selfIntroduction; //プロフィール詳細
  String userId; //ユーザーID(ユーザーに見える)
  Timestamp? createdTime;
  Timestamp? updatedTime;

  //required || = <Type>　：　Nullを許容しない(何かしらの値が入ることを定義)
  Account({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.selfIntroduction,
    required this.userId,
    this.createdTime,
    this.updatedTime,
  });
}
