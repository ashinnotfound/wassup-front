import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../entity/Post.dart';
import '../main.dart';
import '../request/request.dart';
import '../util/wassup_util.dart';

Future<List<Post>> getPosts(BuildContext context) async {
  final List<dynamic> jsonData = await get(
          '${Config.postUrl}post', context.read<MyAppState>().token, context)
      as List<dynamic>;
  final List<Post> posts = jsonData
      .map((post) => Post(
          content: post['content'],
          userId: post['userId'],
          userName: post['userName'],
          userAvatar: post['userAvatar'],
          hasMedia: post['hasMedia'],
          postTime: DateTime.parse(post['postTime']),
          mediaUrls: post['hasMedia']
              ? (post['mediaUrls'] as List<dynamic>)
                  .map((url) => url.toString())
                  .toList()
              : []))
      .toList();

  return posts;
}

Future<void> sendPost(
    BuildContext context, String content, List<Uint8List> imagesBytes) async {
  if (content.isEmpty && imagesBytes.isEmpty) {
    throw "不能发送空贴文😡😡😡我要找一拨人去ganggang你 m3";
  }

  // 纯贴文
  if (imagesBytes.isEmpty) {
    final data = {
      "content": content,
      "hasMedia": false,
    };
    post('${Config.postUrl}post', context.read<MyAppState>().token, data,
        context);
    return;
  }
  try {
    String token = context.read<MyAppState>().token;
    List<String> md5s = [];
    for (final imagesByte in imagesBytes) {
      String md5 = getMd5(imagesByte);
      md5s.add(md5);

      int fiveMb = 5 * 1024 * 1024;

      if (imagesByte.length > fiveMb) {
        int chunkSize = (imagesByte.length / fiveMb).floor();
        var prePostResponse = await post('${Config.postUrl}file/chunk/$md5',
            token, {"chunkSize": chunkSize}, context);
        if (prePostResponse != null) {
          prePostResponse = prePostResponse as Map<String, dynamic>;
          String uploadId = prePostResponse['uploadId'];
          List<String> urls = (prePostResponse['url'] as List<dynamic>)
              .map((url) => url.toString())
              .toList();

          List<Future<void>> uploadFutures = [];
          for (int i = 0; i < chunkSize; i++) {
            var start = i * fiveMb;
            var end = i + 1 == chunkSize ? imagesByte.length : (i + 1) * fiveMb;
            var chunk = imagesByte.sublist(start, end);
            uploadFutures.add(_putChunk(urls[i], chunk, null));
          }
          await Future.wait(uploadFutures);

          await post('${Config.postUrl}file/chunk/$md5/$uploadId', token,
              {"uploadId": uploadId}, context);
        }
      } else {
        await postFormData(
            '${Config.postUrl}file/$md5', token, imagesByte, context);
      }

      final data = {"content": content, "hasMedia": true, "mediaMd5s": md5s};
      post('${Config.postUrl}post', token, data, context);
    }
  } catch (e) {
    rethrow;
  }
}

Future<dynamic> _putChunk(String url, dynamic chunk, int? times) async {
  try {
    times = times ?? 10;
    return put(url, chunk);
  } catch (_) {
    if (times! > 0) {
      return _putChunk(url, chunk, times - 1);
    }
  }
}
