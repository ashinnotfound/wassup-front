import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'config.dart';
import 'main.dart';

class Post {
  final String title;
  final String content;
  final int userId;
  final bool hasMedia;
  final DateTime timestamp;
  final List<String> mediaUrls;

  Post({
    required this.title,
    required this.content,
    required this.userId,
    required this.hasMedia,
    required this.timestamp,
    required this.mediaUrls,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<List<Post>> getPosts(String token) async {
  try {
    var value = await http.get(
      Uri.parse('${Config.postUrl}post'),
      headers: <String, String>{
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
    );
    if (value.statusCode == 200) {
      var responseData = jsonDecode(value.body);
      if (responseData['code'] == 200) {
        return (responseData['data'] as List)
            .map((post) => Post(
                  title: post['title'],
                  content: post['content'],
                  userId: post['userId'],
                  hasMedia: post['hasMedia'],
                  timestamp: DateTime.parse(post['postTime']),
                  mediaUrls: post['hasMedia']
                      ? List<String>.from(post['mediaUrls'])
                      : [],
                ))
            .toList();
      } else {
        throw Exception(responseData['message']);
      }
    } else {
      throw Exception('网络错误');
    }
  } catch (e) {
    rethrow;
  }
}

String getTimeDifference(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays > 0) {
    return '${difference.inDays} 天前';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} 小时前';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} 分钟前';
  } else {
    return '刚刚';
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("let's see some new shit!"),
      ),
      body: FutureBuilder<List<Post>>(
        future: getPosts(context.read<MyAppState>().token),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error.toString()}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            final posts = snapshot.data!;

            return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: posts[index].hasMedia
                          ? Image.network(
                              posts[index].mediaUrls[0],
                              width: 48, // Adjust the width as needed
                              height: 48,
                              fit: BoxFit.cover,
                            )
                          : null,
                      title: Text(posts[index].title),
                      trailing: Text(posts[index].content),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getTimeDifference(posts[index].timestamp)),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.favorite_border),
                              SizedBox(width: 4),
                              Text('0'),
                              SizedBox(width: 16),
                              Icon(Icons.comment),
                              SizedBox(width: 4),
                              Text('0'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
