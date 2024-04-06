import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wassup_front/request/request.dart';
import '../entity/Post.dart';
import '../request/post_request.dart';
import '../util/wassup_util.dart';
import 'component/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("let's see some new shit!"),
      ),
      body: FutureBuilder<List<Post>>(
        future: getPosts(context),
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
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(posts[index].userAvatar),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              posts[index].userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              getTimeDifference(posts[index].postTime),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          posts[index].content,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          alignment: WrapAlignment.end,
                          children: posts[index].mediaUrls.map((url) {
                            return FutureBuilder<Widget>(
                              future: showMedia(url),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                        'Error: ${snapshot.error.toString()}'),
                                  );
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasData) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: SizedBox(
                                      width: 100.0,
                                      height: 100.0,
                                      child: snapshot.data,
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8.0),
                        const Row(
                          children: [
                            Icon(Icons.favorite_border, color: Colors.grey),
                            SizedBox(width: 4.0),
                            Text('0'),
                            SizedBox(width: 16.0),
                            Icon(Icons.comment, color: Colors.grey),
                            SizedBox(width: 4.0),
                            Text('0'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

Future<Widget> showMedia(String url) async {
  Uint8List media = await getFileBytes(url);
  if (media[0] == 0xFF && media[1] == 0xD8) {
    return Image.memory(
      media,
      fit: BoxFit.cover,
    );
  } else {
    return VideoApp(
      videoBytes: media,
    );
  }
}
