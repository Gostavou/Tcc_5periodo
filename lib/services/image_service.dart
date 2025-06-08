import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

import 'dart:html' as html;

class ImageService {
  Future<dynamic> pickImage() async {
    if (kIsWeb) {
      final completer = Completer<html.File?>();
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final file = uploadInput.files?.first;
        completer.complete(file);
      });

      return completer.future;
    } else {
      return null;
    }
  }

  Future<String> uploadProfileImage(String userId, dynamic file) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('user_photos/$userId.jpg');
    UploadTask uploadTask;

    if (kIsWeb) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      final data = reader.result as Uint8List;

      uploadTask =
          storageRef.putData(data, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      uploadTask = storageRef.putFile(File(file.path));
    }

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
