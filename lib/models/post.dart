class Post {
  String postId;
  String email;
  String name;
  String picturePath;
  String title;
  String github;
  String deployedLink;
  String description;
  List<String> screenshots;
  List<String> recordings;
  List<String> likedBy;
  List comments;

  Post({
    this.postId = '',
    this.email = '',
    this.name = '',
    this.picturePath = '',
    this.comments = const [],
    required this.description,
    required this.github,
    required this.deployedLink,
    this.likedBy = const [],
    required this.recordings,
    required this.screenshots,
    required this.title,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['_id'],
      email: json['email'],
      name: json['postedBy']['name'],
      picturePath: json['postedBy']['picturePath'],
      title: json['title'],
      github: json['github'],
      deployedLink: json['deployedLink'],
      description: json['description'],
      screenshots: json['screenshots'].cast<String>(),
      recordings: json['recordings'].cast<String>(),
      likedBy: json['likedBy'].cast<String>(),
      comments: json['comments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'github': github,
      'deployedLink': deployedLink,
      'description': description,
      'screenshots': screenshots,
      'recordings': recordings,
    };
  }
}
