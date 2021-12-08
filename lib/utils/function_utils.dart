import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FunctionUtils {
  //画像選択と保存
  static Future<dynamic> getImageFromGallery() async {
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }

  //画像をFirebaseStorageにアップロードする処理
  static Future<String> uploadImage(String uid, File image) async {
    ImagePicker picker = ImagePicker();
    final FirebaseStorage storageInstance = FirebaseStorage.instance;
    final Reference ref = storageInstance.ref();
    //child(アップロードする画像の名前)
    //image! = nullではないと定義
    await ref.child(uid).putFile(image);
    //画像のリンク取得
    String downloadUrl = await storageInstance.ref(uid).getDownloadURL();
    print("image Path $downloadUrl");
    return downloadUrl;
  }
}
