String timeAgo(DateTime date) {
  Duration diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) {
    return "${diff.inSeconds} s ago";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} min ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hour ago";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} day ago";
  } else if (diff.inDays < 30) {
    return "${(diff.inDays / 7).floor()} weeks ago";
  } else if (diff.inDays < 365) {
    return "${(diff.inDays / 30).floor()} month ago";
  } else {
    return "${(diff.inDays / 365).floor()} year ago";
  }
}
