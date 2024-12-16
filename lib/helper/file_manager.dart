import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class FileManager {
  FileManager._();
  static FileManager instance = FileManager._();

  String? downloadPath;

  Future<ShareResult> shareImage(Uint8List image) {
    return Share.shareXFiles(
      [
        XFile.fromData(image,
            mimeType: "image/jpg",
            name: "EmojiPic_${DateTime.now().toString()}.jpg")
      ],
      subject: "Emoji Picture",
      text: "Check out my Emoji Picture",
    );
  }

  Future<void> saveToGallery(Uint8List data) async {
    bool hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      log("Requesting Access", name: "saveToGallery");
      await Gal.requestAccess(toAlbum: true);
    }
    hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      log("Access Denied. Cancelling!", name: "saveToGallery");
      return;
    }
    return Gal.putImageBytes(
      data,
      album: "Emojigraphy",
      name: "EmojiPic_${DateTime.now().toString()}.jpg",
    );
  }

  Future<void> saveToDownload(Uint8List data, String name, String ext) async {
    if (!await Permission.storage.request().isGranted) {
      log("Permission Denied", name: "saveToDownload");
      return;
    }
    downloadPath ??= await _getDownloadsPath();
    String filePath = await availablePath("${downloadPath!}/$name", ext);
    File file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(data);
    log("Saved: $filePath", name: "saveToDownload");
  }

  Future<String> _getDownloadsPath() async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download";
    } else {
      String? path = (await getDownloadsDirectory())?.path;
      path ??= (await getApplicationDocumentsDirectory()).path;
      return path;
    }
  }

  Future<String> availablePath(String path, String ext) async {
    File file = File("$path.$ext");
    if (await file.exists()) return "$path.$ext";
    int count = 0;
    while (await file.exists()) {
      count++;
      file = File("$path($count).$ext");
    }
    return "$path($count).$ext";
  }
}
