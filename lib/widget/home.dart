import 'dart:math';
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
  List<Post>? _posts;
  final Set<int> _shownPostIndices = {};

  @override
  void initState() {
    super.initState();
    try {
      _initPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initPosts() async {
    try {
      setState(() {
        _posts = null;
      });
      final posts = await getPosts(context);
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("let's see some new shit!"),
        actions: [
          ElevatedButton(
            onPressed: () => setState(() {
              _shownPostIndices.clear();
            }),
            child: const Text('刷新'),
          ),
        ],
      ),
      body: _posts == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300.0,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        int randomIndex;
                        do {
                          randomIndex = Random().nextInt(_posts!.length);
                        } while (_shownPostIndices.contains(randomIndex));
                        _shownPostIndices.add(randomIndex);
                        final post = _posts![randomIndex];
                        return buildPostCard(post);
                      },
                      childCount: _posts!.length <= 8 ? _posts!.length : 8,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildPostCard(Post post) {
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
                  backgroundImage: NetworkImage(post.userAvatar),
                ),
                const SizedBox(width: 8.0),
                Text(
                  post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const Spacer(),
                Text(
                  getTimeDifference(post.postTime),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Wrap(
              alignment: WrapAlignment.end,
              children: post.mediaUrls.map((url) {
                return FutureBuilder<Widget>(
                  future: showMedia(url),
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
