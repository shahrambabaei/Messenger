import 'dart:developer';

import 'package:chat_app/utils/matrix_file_extension.dart';
import 'package:chat_app/utils/size_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:matrix/matrix.dart';

extension LocalizedBody on Event {
  Future<LoadingDialogResult<MatrixFile>> _getFile(BuildContext context) =>
      showFutureLoadingDialog(
          context: context,
          barrierDismissible: false,
          onError: (_) {
            return "خطا در ‌ذخیره سازی";
          },
          future: downloadAndDecryptAttachment);

  void saveFile(BuildContext context) async {
    final matrixFile = await _getFile(context);
    matrixFile.result?.save(context);
  }

  void shareFile(BuildContext context) async {
    final matrixFile = await _getFile(context);
    inspect(matrixFile);

    // matrixFile.result?.share(context);
  }

  bool get isAttachmentSmallEnough =>
      infoMap['size'] is int &&
      infoMap['size'] < room.client.database!.maxFileSize;

  bool get isThumbnailSmallEnough =>
      thumbnailInfoMap['size'] is int &&
      thumbnailInfoMap['size'] < room.client.database!.maxFileSize;

  bool get showThumbnail =>
      [MessageTypes.Image, MessageTypes.Sticker, MessageTypes.Video]
          .contains(messageType) &&
      (kIsWeb ||
          isAttachmentSmallEnough ||
          isThumbnailSmallEnough ||
          (content['url'] is String));

  String? get sizeString => content
      .tryGetMap<String, dynamic>('info')
      ?.tryGet<int>('size')
      ?.sizeString;
}
