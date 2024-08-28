class Feed {
  String postId;
  String title;
  String name;
  String picturePath;

  Feed({
    required this.postId,
    required this.title,
    required this.name,
    required this.picturePath,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      postId: json['_id'],
      title: json['title'],
      name: json['name'],
      picturePath: json['picturePath'],
    );
  }
}
