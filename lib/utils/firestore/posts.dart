import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_sns_app/model/post.dart';
import 'package:firebase_storage/firebase_storage.dart';

/* 投稿管理 */
class PostFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  //全てのユーザーの投稿が保存されている "posts" コレクション
  static final CollectionReference posts =
      _firestoreInstance.collection("posts");

  static Future<dynamic> addPost(Post newPost) async {
    try {
      final CollectionReference _userPosts = _firestoreInstance
          .collection('users')
          .doc(newPost.postAccountId)
          .collection('my_posts'); //当人のみの投稿が保存されている 'my_posts' コレクション
      //全ての投稿が保存されている "posts" コレクションに投稿を追加
      var result = await posts.add({
        'content': newPost.content,
        'post_account_id': newPost.postAccountId,
        'created_time': Timestamp.now()
      });
      //ドキュメントで当人のIDを用いて、当人のみの投稿が保存されている 'my_posts' コレクションに投稿を追加
      _userPosts
          .doc(result.id)
          .set({'post_id': result.id, 'created_time': Timestamp.now()});
      print('投稿完了');
      return true;
    } on FirebaseException catch (e) {
      print('投稿error: $e');
      return false;
    }
  }

  //"my_posts" コレクションにある自分の投稿したデータのIDを取得
  static Future<List<Post>?> getPostsFromIds(List<String> ids) async {
    List<Post> postList = [];
    try {
      //"posts" コレクションのドキュメントから、自分の投稿したデータを取得
      await Future.forEach(ids, (String id) async {
        var doc = await posts.doc(id).get();
        //オブジェクト型をMap型に変換
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Post post = Post(
            id: doc.id,
            content: data['content'],
            postAccountId: data['post_account_id'],
            createdTime: data['created_time']);
        postList.add(post);
      });
      print("自分の投稿を取得");
      return postList;
    } on FirebaseException catch (e) {
      print("自分の投稿を取得Error: $e");
      return null;
    }
  }

  //FireStoreの 'users<'my_posts'' &'posts' コレクション下にあるユーザー情報を削除
  static Future<dynamic> deletePosts(String accountId) async {
    //削除されたユーザーの投稿情報を取得
    final CollectionReference _userPosts = _firestoreInstance
        .collection('users')
        .doc(accountId)
        .collection('my_posts');
    //Cloud FireStore < users < doc < my_posts を取得
    var snapshot = await _userPosts.get();
    /* 投稿削除 */
    snapshot.docs.forEach((doc) async {
      //postsコレクションの情報を削除
      await posts.doc(doc.id).delete();
      //usersコレクションの情報を削除
      _userPosts.doc(doc.id).delete();
    });
  }
}
