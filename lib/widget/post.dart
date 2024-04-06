import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wassup_front/request/post_request.dart';

import 'component/video_player.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _contentController = TextEditingController();
  final List<Uint8List> _selectedImages = [];

  void _submitPost() async {
    final content = _contentController.text.trim();

    try {
      await sendPost(context, content, _selectedImages);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('发送成功！🎉🎉🎉'),
        backgroundColor: Colors.green,
      ));

      setState(() {
        _contentController.clear();
        _selectedImages.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _selectImages() {
    final inputElement = FileUploadInputElement()
      ..accept = 'image/*,video/*'
      ..multiple = true
      ..click();

    inputElement.onChange.listen((event) {
      final files = inputElement.files;
      if (files != null) {
        for (final file in files) {
          _readFileAsBytesAndAddToList(file);
        }
      }
    });
  }

  Future<void> _readFileAsBytesAndAddToList(File file) async {
    final fileReader = FileReader();
    fileReader.readAsArrayBuffer(file);
    await fileReader.onLoadEnd.first;
    final bytes = Uint8List.fromList(fileReader.result as List<int>);
    setState(() {
      _selectedImages.add(bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('come and make some new shit!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '哥们真帅🥰',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _selectImages,
              child: const Text('选择图片'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.start,
                children: _selectedImages.map((media) {
                  if (media[0] == 0xFF && media[1] == 0xD8) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 100.0,
                        height: 100.0,
                        child: Image.memory(
                          media,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: VideoApp(
                            videoBytes: media,
                          ),
                        ));
                  }
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitPost,
              child: const Text('发送'),
            ),
          ],
        ),
      ),
    );
  }
}
