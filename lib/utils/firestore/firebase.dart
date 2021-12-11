import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sns_app/model/account.dart';
import 'package:firebase_sns_app/utils/authentication.dart';

class Firestore {
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userRef = _firestoreInstance.collection("user");
  static final roomRef = _firestoreInstance.collection("room");
  /*roomコレクションに値が追加された時UIを更新するのに使用*/
  // snapshots とは、ある時点における特定のデータベース参照にあるデータの全体像を写し取ったもの
  static final roomSnapshot = roomRef.snapshots();

  static Future<void> addFireStoreRoom(String uId) async {
    //自分
    Account myAccount = Authentication.myAccount!;
    //相手
    String uAccount = uId;
    try {
      if (myAccount.id != uAccount) {
        await roomRef.add({
          ///トーク相手と自分自身のIDを追加
          ///ex) uAccount(相手(A))  myAccount(自分(C))
          'joined_user_ids': [uAccount, myAccount.id],
          'updated_time': Timestamp.now()
        });
        print('ルーム作成完了');
      }
    } catch (e) {
      print('ルーム作成Erro: $e');
    }
  }
}
