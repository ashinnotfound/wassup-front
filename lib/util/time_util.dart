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