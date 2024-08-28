import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:projects_app/models/post.dart';
import 'package:projects_app/models/post_preview.dart';
import 'package:projects_app/models/user.dart';
import 'package:projects_app/utilities/constants.dart';
import 'package:projects_app/utilities/secure_storage.dart';
import 'package:projects_app/models/feed.dart';

final isConnectedProvider = StateProvider<bool>((ref) => false);

final registerUserProvider = StateProvider<User>((ref) {
  return User(name: '', email: '', password: '');
});

final registerProvider = FutureProvider<String>((ref) async {
  String uri = "$localhost/register";
  final body = ref.watch(registerUserProvider);
  final res = await http.post(
    Uri.parse(uri),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body.toRegisterJson()),
  );
  if (res.statusCode == 201) {
    final resBody = jsonDecode(res.body);
    return resBody['token'];
  } else {
    return '';
  }
});

final loginUserProvider = StateProvider<User>((ref) {
  return User(email: '', password: '');
});

final loginProvider = FutureProvider<String>((ref) async {
  String uri = '$localhost/login';
  final body = ref.watch(loginUserProvider);
  final res = await http.post(
    Uri.parse(uri),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body.toLoginJson()),
  );
  if (res.statusCode == 200) {
    final resBody = jsonDecode(res.body);
    return resBody['token'];
  } else {
    return '';
  }
});

final loggedUserProvider = FutureProvider<User?>((ref) async {
  final token = await SecureStorage.readData();
  ref.read(tokenProvider.notifier).state = token!;
  final email = JwtDecoder.decode(token)['email'];
  String uri = '$localhost/users/$email';
  final res = await http.get(
    Uri.parse(uri),
    headers: {'Content-Type': 'application/json'},
  );
  if (res.statusCode == 200) {
    final user = jsonDecode(res.body)['user'];
    return User.fromJson(user);
  } else {
    return null;
  }
});

final tokenProvider = StateProvider<String>((ref) {
  return '';
});

final verifyTokenProvider = FutureProvider((ref) async {
  final token = await SecureStorage.readData();
  if (token == null || token.isEmpty) {
    return false;
  }

  String uri = '$localhost/verifyjwt';
  final body = {'token': token};
  final res = await http.post(
    Uri.parse(uri),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  if (res.statusCode == 200) {
    return true;
  } else {
    return false;
  }
});

final feedProvider = FutureProvider<List<Feed>?>((ref) async {
  String uri = '$localhost/posts/more/feed';
  final token = await SecureStorage.readData();
  final res = await http.get(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  if (res.statusCode == 200) {
    final feed = jsonDecode(res.body)['feed'];
    print('Feed: $feed');
    final List<Feed> list = [];
    for (var post in feed) {
      print('loop Post: $post');
      list.add(Feed.fromJson(post));
    }
    print('kya hua');
    print('List: $list');
    return list;
  } else {
    return null;
  }
});

final selectedPostIdProvider = StateProvider<String>((ref) {
  return '';
});

final selectedPostProvider = FutureProvider<Post?>((ref) async {
  final postId = ref.watch(selectedPostIdProvider);
  final token = await SecureStorage.readData();
  String uri = '$localhost/posts/$postId';
  final res = await http.get(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'applicaton/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 200) {
    final resBody = res.body;
    final post = jsonDecode(resBody)['post'];
    return Post.fromJson(post);
  } else {
    return null;
  }
});

final selectedVideoProvider = StateProvider<String>((ref) {
  return '';
});

final likePostProvider = FutureProvider<bool>((ref) async {
  final postId = ref.watch(selectedPostIdProvider);
  final token = await SecureStorage.readData();
  String uri = '$localhost/posts/more/like';
  final res = await http.patch(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'postId': postId}),
  );
  if (res.statusCode == 200) {
    return true;
  }
  return false;
});

final isLikedProvider = StateProvider<bool>((ref) {
  return false;
});

final commentProvider = StateProvider<String>((ref) {
  return '';
});

final addCommentProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  String uri = '$localhost/posts/more/comment';
  final token = await SecureStorage.readData();
  final comment = ref.watch(commentProvider);
  final postId = ref.watch(selectedPostIdProvider);
  final body = {
    'postId': postId,
    'comment': comment,
  };
  final res = await http.patch(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  if (res.statusCode == 201) {
    final resBody = jsonDecode(res.body);
    return resBody['comment'];
  } else {
    return null;
  }
});

final screenshotsProvider = StateProvider<List<XFile>>((ref) {
  return [];
});

final recordingsProvider = StateProvider<List<XFile>>((ref) {
  return [];
});

final recordingsThumbnailProvider = StateProvider<List<Uint8List>>((ref) {
  return [];
});

final postTitleProvider = StateProvider((ref) {
  return '';
});

final postDescProvider = StateProvider((ref) {
  return '';
});

final postGithubProvider = StateProvider((ref) {
  return '';
});

final postDeployedProvider = StateProvider((ref) {
  return '';
});

final createdPostProvider = StateProvider<Post?>((ref) {
  return null;
});

final createPostProvider = FutureProvider<bool>((ref) async {
  String uri = '$localhost/posts';
  final token = await SecureStorage.readData();
  final post = ref.watch(createdPostProvider);
  final res = await http.post(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
    body: jsonEncode(post!.toJson()),
  );

  if (res.statusCode == 201) {
    return true;
  } else {
    return false;
  }
});

final searchStringProvider = StateProvider<String>((ref) => '');

final searchUserProvider = FutureProvider<List>((ref) async {
  final searchString = ref.watch(searchStringProvider);
  if (searchString.isEmpty) {
    return [];
  }
  final token = await SecureStorage.readData();
  String uri = '$localhost/users/search/$searchString';
  final res = await http.get(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  if (res.statusCode == 200) {
    return jsonDecode(res.body)['users'];
  } else {
    return [];
  }
});

final selectedUserEmailProvider = StateProvider<String>((ref) => '');

final getUserProvider = FutureProvider<User?>((ref) async {
  final email = ref.watch(selectedUserEmailProvider);
  String uri = '$localhost/users/$email';
  final res = await http.get(
    Uri.parse(uri),
    headers: {'Content-Type': 'application/json'},
  );

  if (res.statusCode == 200) {
    final resBody = jsonDecode(res.body);
    return User.fromJson(resBody['user']);
  } else {
    return null;
  }
});

final getPostsProvider = FutureProvider<List<PostPreview>>((ref) async {
  final email = ref.watch(selectedUserEmailProvider);
  String uri = '$localhost/posts?email=$email';
  final res = await http.get(
    Uri.parse(uri),
    headers: {'Content-Type': 'application/json'},
  );

  if (res.statusCode == 200) {
    List<PostPreview> list = [];
    final resBody = jsonDecode(res.body);
    for (var post in resBody['posts']) {
      list.add(PostPreview.fromJson(post));
    }
    return list;
  } else {
    return [];
  }
});

final followUserProvider = FutureProvider<bool?>((ref) async {
  String uri = '$localhost/users/follow';
  final token = await SecureStorage.readData();
  final selectedUserEmail = ref.watch(selectedUserEmailProvider);
  final body = {'email': selectedUserEmail};
  final res = await http.patch(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  if (res.statusCode == 200) {
    final resBody = jsonDecode(res.body);
    return resBody['followed'];
  } else {
    return null;
  }
});

final deletePostIdProvider = StateProvider((ref) => '');

final deletePostProvider = FutureProvider<bool>((ref) async {
  final id = ref.watch(deletePostIdProvider);
  String uri = '$localhost/posts/$id';
  final token = await SecureStorage.readData();
  final res = await http.delete(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 204) {
    return true;
  } else {
    return false;
  }
});

final newProfilePicProvider = StateProvider<CroppedFile?>((ref) => null);
final newProfilePicUrlProvider = StateProvider<String>((ref) => '');
final newNameProvider = StateProvider<String>((ref) => '');

final updateUserProvider = FutureProvider<bool>((ref) async {
  String uri = '$localhost/users/';
  final token = await SecureStorage.readData();
  final picturePath = ref.watch(newProfilePicUrlProvider);
  final name = ref.watch(newNameProvider);
  final body = {
    'picturePath': picturePath,
    'name': name,
  };
  final res = await http.patch(
    Uri.parse(uri),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),
  );

  if(res.statusCode == 200) {
    return true;
  } else {
    return false;
  }
});
