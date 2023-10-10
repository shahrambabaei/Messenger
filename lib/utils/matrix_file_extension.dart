import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

extension MatrixFileExtension on MatrixFile {
  void save(BuildContext context) async {
    if (Platform.isIOS) {
      return share(context);
    }

    if (kIsWeb) {
      _webDownload();
      return;
    }

    final downloadPath = Platform.isAndroid
        ? await getDownloadPathAndroid()
        : await FilePicker.platform.saveFile(
            dialogTitle: "ذخیره فایل",
            fileName: name,
            type: filePickerFileType,
          );
    if (downloadPath == null) return;

    final result = await showFutureLoadingDialog(
      context: context,
      future: () => File(downloadPath).writeAsBytes(bytes),
    );
    if (result.error != null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
        
           downloadPath
          ,
        ),
      ),
    );
  }

  Future<String> getDownloadPathAndroid() async {
    final directory = await getDownloadDirectoryAndroid();
    return '${directory.path}/$name';
  }

  Future<Directory> getDownloadDirectoryAndroid() async {
    final defaultDownloadDirectory = Directory('/storage/emulated/0/Download');
    if (await defaultDownloadDirectory.exists()) {
      return defaultDownloadDirectory;
    }
    return await getApplicationDocumentsDirectory();
  }

  void share(BuildContext context) async {
    // Workaround for iPad from
    // https://github.com/fluttercommunity/plus_plugins/tree/main/packages/share_plus/share_plus#ipad
    final box = context.findRenderObject() as RenderBox;

    await Share.shareXFiles(
      [XFile.fromData(bytes, name: name, mimeType: mimeType)],
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
    return;
  }

  FileType get filePickerFileType {
    if (this is MatrixImageFile) return FileType.image;
    if (this is MatrixAudioFile) return FileType.audio;
    if (this is MatrixVideoFile) return FileType.video;
    return FileType.any;
  }

  void _webDownload() {
    html.AnchorElement(
      href: html.Url.createObjectUrlFromBlob(
        html.Blob(
          [bytes],
          mimeType,
        ),
      ),
    )
      ..download = name
      ..click();
  }

  MatrixFile get detectFileType {
    if (msgType == MessageTypes.Image) {
      return MatrixImageFile(bytes: bytes, name: name);
    }
    if (msgType == MessageTypes.Video) {
      return MatrixVideoFile(bytes: bytes, name: name);
    }
    if (msgType == MessageTypes.Audio) {
      return MatrixAudioFile(bytes: bytes, name: name);
    }
    return this;
  }
}
