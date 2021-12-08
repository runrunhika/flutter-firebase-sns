import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sns_app/model/account.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static User? currentFirebaseUser;
  static Account? myAccount;

  //サインアップ処理
  static Future<dynamic> signUp(
      {required String email, required String pass}) async {
    try {
      //登録したユーザー情報を取得
      UserCredential newAccount = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: pass);
      print("auth finish");
      //取得したユーザー情報を返す
      return newAccount;
    } on FirebaseAuthException catch (e) {
      print("auth error: $e");
      return false;
    }
  }

  //認証（ログイン）処理
  static Future<dynamic> emailSignIn(
      {required String email, required String pass}) async {
    try {
      final UserCredential _result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: pass);
      currentFirebaseUser = _result.user;
      print("auth signIn complete");
      return _result;
    } on FirebaseAuthException catch (e) {
      print("auth signIn error: $e");
      return false;
    }
  }

  static Future<dynamic> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      //Googleのアカウントがある場合
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
        final UserCredential _result =
            await _firebaseAuth.signInWithCredential(credential);
        currentFirebaseUser = _result.user;
        print('グーグルログインcomplete');
        return _result;
      }
    } on FirebaseAuthException catch (e) {
      print('グーグルログインerro: $e ');
      return false;
    }
  }

  //ログアウト
  static Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  //Firebase Authentication のユーザー情報を削除
  static Future<void> deleteAuth() async {
    await currentFirebaseUser!.delete();
  }
}
