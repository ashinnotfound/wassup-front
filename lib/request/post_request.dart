import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/config.dart';
import '../entity/Post.dart';
import '../main.dart';
import '../request/request.dart';

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
          mediaUrls: (post['mediaUrls'] as List<dynamic>)
              .map((url) => url.toString())
              .toList()))
      .toList();

  return posts;
}