import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wassup_front/config/config.dart';

import '../main.dart';

Future<dynamic> get(String url, String? token, BuildContext context) async {
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    var response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['code'] == 200) {
        return responseData['data'];
      } else if (responseData['code'] == 402) {
        // 刷新token
        return get(url, refreshToken(token, context), context);
      } else {
        throw responseData['message'];
      }
    } else {
      throw "网络错误";
    }
  } catch (e) {
    rethrow;
  }
}

Future<dynamic> getFileBytes(String url) async {
  try {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw "网络错误";
    }
  } catch (e) {
    rethrow;
  }
}

Future<dynamic> post(
    String url, String? token, dynamic data, BuildContext context) async {
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['code'] == 200) {
        return responseData['data'];
      } else if (responseData['code'] == 402) {
        // 刷新token
        return post(url, refreshToken(token, context), data, context);
      } else {
        throw responseData['message'];
      }
    } else {
      throw "网络错误";
    }
  } catch (e) {
    rethrow;
  }
}

Future<dynamic> postFormData(String url, String? token, Uint8List fileBytes,
    BuildContext context) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: 'file',
    );
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var decodedData = jsonDecode(responseData);
      if (decodedData['code'] == 200) {
        return decodedData['data'];
      } else if (decodedData['code'] == 402) {
        // 刷新token
        return postFormData(
            url, refreshToken(token, context), fileBytes, context);
      } else {
        throw decodedData['message'];
      }
    } else {
      throw "网络错误";
    }
  } catch (e) {
    rethrow;
  }
}

Future<dynamic> put(String url, dynamic data) async {
  try {
    var response = await http.put(
      Uri.parse(url),
      body: data,
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw "网络错误";
    }
  } catch (e) {
    rethrow;
  }
}

String refreshToken(String? token, BuildContext context) {
  try {
    String newToken =
        post('${Config.authUrl}auth/refresh', token, null, context) as String;

    if (context.mounted) {
      context.read<MyAppState>().updateToken(newToken);
    }

    return newToken;
  } catch (e) {
    rethrow;
  }
}
