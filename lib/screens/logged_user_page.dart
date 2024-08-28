import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:projects_app/screens/edit_profile_page.dart';
import 'package:projects_app/screens/login_page.dart';
import 'package:projects_app/screens/post_page.dart';
import 'package:projects_app/utilities/providers.dart';
import 'package:projects_app/utilities/secure_storage.dart';

class LoggedUserPage extends ConsumerStatefulWidget {
  const LoggedUserPage({super.key});

  @override
  ConsumerState<LoggedUserPage> createState() => _LoggedUserPageState();
}

class _LoggedUserPageState extends ConsumerState<LoggedUserPage> {
  Future<bool> isLikedFn() async {
    final token = ref.watch(tokenProvider);
    final email = JwtDecoder.decode(token)['email'];
    final post = await ref.refresh(selectedPostProvider.future);
    if (post!.likedBy.contains(email)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(loggedUserProvider).when(
      data: (data) {
        var posts = ref.watch(getPostsProvider);
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.white,
            title: Text(
              data!.name!,
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await SecureStorage.deleteData();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Image.network(data.picturePath!),
                        ),
                        // const SizedBox(width: 80),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Followers',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    data.followers!.length.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              // SizedBox(width: 30),
                              Column(
                                children: [
                                  const Text(
                                    'Following',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    data.following!.length.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      data.name!,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      data.email,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          ref.read(newProfilePicProvider.notifier).state = null;
                          ref.read(newProfilePicUrlProvider.notifier).state =
                              data.picturePath!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                        child: const Text('Edit profile'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                posts.when(
                  data: (data) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            onTap: () async {
                              ref.read(selectedPostIdProvider.notifier).state =
                                  data[index].postId;
                              ref.read(isLikedProvider.notifier).state =
                                  await isLikedFn();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PostPage(),
                                ),
                              );
                            },
                            child: Ink(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade800,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 16.0,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data[index].title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              data[index].description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton(
                                          color: Colors.white,
                                          iconColor: Colors.white,
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Delete'),
                                                  Icon(Icons.delete),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (val) async {
                                            if (val == 1) {
                                              ref
                                                  .read(deletePostIdProvider
                                                      .notifier)
                                                  .state = data[index].postId;
                                              await ref.watch(
                                                  deletePostProvider.future);
                                              posts =
                                                  ref.refresh(getPostsProvider);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (error, st) {
                    print(error);
                    print(st);
                    return const Text('some error occurred');
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      error: (error, st) {
        print(error);
        print(st);
        return const Text('some error occurred');
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
