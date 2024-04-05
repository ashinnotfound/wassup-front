class Post {
  final String content;
  final int userId;
  final String userName;
  final String userAvatar;
  final bool hasMedia;
  final DateTime postTime;
  final List<String> mediaUrls;

  Post({
    required this.content,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.hasMedia,
    required this.postTime,
    required this.mediaUrls,
  });
}
