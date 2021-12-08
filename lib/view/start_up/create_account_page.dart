import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_sns_app/model/account.dart';
import 'package:firebase_sns_app/utils/authentication.dart';
import 'package:firebase_sns_app/utils/firestore/users.dart';
import 'package:firebase_sns_app/utils/function_utils.dart';
import 'package:firebase_sns_app/utils/widget_utils.dart';
import 'package:firebase_sns_app/view/screen.dart';
import 'package:firebase_sns_app/view/start_up/check_email_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateAccountPage extends StatefulWidget {
  //GoogleでSignInする場合、Emailの入力はしなくても良いから、表示・非表示の判定
  final bool isSignInWithGoogle;
  const CreateAccountPage({Key? key, this.isSignInWithGoogle = false})
      : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar("新規登録"),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              //TapできないWidgetをTapできるようにする
              GestureDetector(
                onTap: () async {
                  var result = await FunctionUtils.getImageFromGallery();
                  if (result != null) {
                    setState(() {
                      image = File(result.path);
                    });
                  }
                },
                child: CircleAvatar(
                  foregroundImage: image == null ? null : FileImage(image!),
                  radius: 40,
                  child: Icon(Icons.add),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "名前"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                  width: 300,
                  child: TextField(
                    controller: userIdController,
                    decoration: InputDecoration(hintText: "ユーザーID"),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  controller: selfIntroductionController,
                  decoration: InputDecoration(hintText: "自己紹介"),
                ),
              ),
              widget.isSignInWithGoogle
                  ? Container()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                      ],
                    ),

              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty &&
                        selfIntroductionController.text.isNotEmpty &&
                        image != null) {
                          //Google認証の場合
                      if (widget.isSignInWithGoogle) {
                        var _result = await createAccount(
                            Authentication.currentFirebaseUser!.uid);
                        if (_result) {
                          await UserFirestore.getUser(
                              Authentication.currentFirebaseUser!.uid);
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Screen()));
                        }
                      }
                      var result = await Authentication.signUp(
                          email: emailController.text,
                          pass: passController.text);
                      //resultから返された値が newAccount なら UserCredentialなのでtrueになる
                      if (result is UserCredential) {
                        var _result = await createAccount(result.user!.uid);
                        if (_result) {
                          //メール送信
                          result.user!.sendEmailVerification();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CheckEmailPage(
                                      email: emailController.text,
                                      pass: passController.text)));
                        }
                      }
                    }
                  },
                  child: Text("アカウントを作成"))
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> createAccount(String uid) async {
//アップロード終了後に画面遷移させるために await をつける
    //登録したユーザーIDがアップロードする画像のPath名になる
    //user! 登録するユーザーの値はNullではないと定義
    String imagePath = await FunctionUtils.uploadImage(uid, image!);
    //FireStoreに保存する新規アカウントの情報をセットする
    Account newAccount = Account(
      id: uid,
      name: nameController.text,
      userId: userIdController.text,
      selfIntroduction: selfIntroductionController.text,
      imagePath: imagePath,
    );
    //新規アカウントの情報をFireStoreに保存する
    var _result = await UserFirestore.setUser(newAccount);
    return _result;
  }
}
