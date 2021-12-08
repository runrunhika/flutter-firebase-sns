import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sns_app/utils/authentication.dart';
import 'package:firebase_sns_app/utils/firestore/users.dart';
import 'package:firebase_sns_app/utils/widget_utils.dart';
import 'package:firebase_sns_app/view/screen.dart';
import 'package:flutter/material.dart';

class CheckEmailPage extends StatefulWidget {
  final String email;
  final String pass;
  const CheckEmailPage({Key? key, required this.email, required this.pass})
      : super(key: key);

  @override
  _CheckEmailPageState createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar("メールアドレスを確認"),
      body: Column(
        children: [
          Text(
              "ご登録いただいたメールアドレス宛に確認のメールを送信しております。そちらに記載されているURLをクリックし認証をお願いいたします"),
          ElevatedButton(
              onPressed: () async {
                /* ログイン認証 */
                //Email&Password取得
                var result = await Authentication.emailSignIn(
                    email: widget.email, pass: widget.pass);
                //ログイン認証成功の場合
                if (result is UserCredential) {
                  //Email認証成功の場合
                  if (result.user!.emailVerified) {
                    //戻れるところまでPopする
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    //ユーザー情報取得
                    await UserFirestore.getUser(result.user!.uid);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Screen()));
                  } else {
                    print("メール認証おわってへんで");
                  }
                }
              },
              child: Text("認証完了"))
        ],
      ),
    );
  }
}
