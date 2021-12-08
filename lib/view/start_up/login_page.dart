import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sns_app/utils/authentication.dart';
import 'package:firebase_sns_app/utils/firestore/users.dart';
import 'package:firebase_sns_app/view/screen.dart';
import 'package:firebase_sns_app/view/start_up/create_account_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                "Flutter Test SNS",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(hintText: "メールアドレス"),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: passController,
                  decoration: InputDecoration(hintText: "パスワード"),
                ),
              ),
              RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                    TextSpan(text: "アカウントを作成していない方は"),
                    TextSpan(
                        text: "こちら",
                        style: TextStyle(color: Colors.blue),
                        //Button機能を付与
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateAccountPage()));
                          })
                  ])),
              SizedBox(
                height: 70,
              ),
              ElevatedButton(
                  onPressed: () async {
                    var result = await Authentication.emailSignIn(
                        email: emailController.text, pass: passController.text);
                    if (result is UserCredential) {
                      if (result.user!.emailVerified) {
                        var _result =
                            await UserFirestore.getUser(result.user!.uid);
                        if (_result) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Screen()));
                        } else {
                          print('メール認証できてません');
                        }
                      }
                    }
                  },
                  child: Text("Emailでログイン")),
              SignInButton(Buttons.Google, onPressed: () async {
                var result = await Authentication.signInWithGoogle();
                if (result is UserCredential) {
                  //Cloud FireStore からユーザー情報を取得 (true: 過去にアカウント作成している)
                  var result = await UserFirestore.getUser(
                      Authentication.currentFirebaseUser!.uid);

                  if (result) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Screen()));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateAccountPage()));
                  }
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}

/* Google認証の場合　Fire Base Authの設定後　以下をTerminalで実行*/
///mac
///keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
///windows
///keytool -list -v keystore "\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
///
///SHA1: ~~~  をCopy
///Firebase Android＜フィンガープリント追加にPaste