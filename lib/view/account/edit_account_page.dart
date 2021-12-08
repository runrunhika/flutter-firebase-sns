import 'dart:io';

import 'package:firebase_sns_app/model/account.dart';
import 'package:firebase_sns_app/utils/authentication.dart';
import 'package:firebase_sns_app/utils/firestore/users.dart';
import 'package:firebase_sns_app/utils/function_utils.dart';
import 'package:firebase_sns_app/utils/widget_utils.dart';
import 'package:firebase_sns_app/view/start_up/login_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({Key? key}) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  //編集するユーザー自身のアカウント
  Account myAccount = Authentication.myAccount!;
  TextEditingController nameController = TextEditingController();
  TextEditingController userIdController = TextEditingController();
  TextEditingController selfIntroductionController = TextEditingController();
  File? image;

  ImageProvider getImage() {
    //画像を変更しない場合は、すでに設定しているプロフィール画像をセットし表示する
    if (image == null) {
      return NetworkImage(myAccount.imagePath);
    } //画像を変更する場合、変更する画像へUI更新
    else {
      return FileImage(image!);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: myAccount.name);
    userIdController = TextEditingController(text: myAccount.userId);
    selfIntroductionController =
        TextEditingController(text: myAccount.selfIntroduction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetUtils.createAppBar("プロフィール編集"),
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
                  foregroundImage: getImage(),
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
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        userIdController.text.isNotEmpty &&
                        selfIntroductionController.text.isNotEmpty) {
                      String imagePath = "";
                      //画像を更新しない場合
                      if (image == null) {
                        //すでに設定されている画像を設定
                        imagePath = myAccount.imagePath;
                      } //画像を更新する場合
                      else {
                        var result = await FunctionUtils.uploadImage(
                            myAccount.id, image!);
                        imagePath = result;
                      }
                      //編集したユーザー情報を変数(updateAccount)へ入れる
                      Account updateAccount = Account(
                        id: myAccount.id,
                        name: nameController.text,
                        userId: userIdController.text,
                        selfIntroduction: selfIntroductionController.text,
                        imagePath: imagePath,
                      );
                      //ユーザー情報更新
                      Authentication.myAccount = updateAccount;
                      //サーバー側のユーザー情報更新
                      var result =
                          await UserFirestore.updateUser(updateAccount);
                      if (result) {
                        Navigator.pop(context, null);
                      }
                    }
                  },
                  child: Text("更新")),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  onPressed: () {
                    Authentication.signOut();
                    //Popできる状態なら、Popする
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text("ログアウト")),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  onPressed: () {
                    UserFirestore.deleteUser(myAccount.id);
                    Authentication.deleteAuth();
                    while (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text("アカウントを削除")),
            ],
          ),
        ),
      ),
    );
  }
}
