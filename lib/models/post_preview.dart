class PostPreview {
  String postId;
  String title;
  String description;

  PostPreview({
    required this.postId,
    required this.title,
    required this.description,
  });

  factory PostPreview.fromJson(Map<String, dynamic> json) {
    return PostPreview(
      postId: json['_id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
