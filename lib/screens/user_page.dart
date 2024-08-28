import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:projects_app/screens/post_page.dart';
import 'package:projects_app/utilities/providers.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
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
    var user = ref.watch(getUserProvider);
    return user.when(
      data: (data) {
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade900,
            foregroundColor: Colors.white,
            title: Text(data!.name!),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    // SizedBox(height: 20),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: data.followers!.contains(
                                  JwtDecoder.decode(
                                      ref.watch(tokenProvider))['email'])
                              ? Colors.transparent
                              : Colors.yellow,
                          foregroundColor: data.followers!.contains(
                                  JwtDecoder.decode(
                                      ref.watch(tokenProvider))['email'])
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: data.followers!.contains(JwtDecoder.decode(
                                    ref.watch(tokenProvider))['email'])
                                ? const BorderSide(color: Colors.transparent)
                                : const BorderSide(color: Colors.grey),
                          ),
                        ),
                        onPressed: () async {
                          await ref.refresh(followUserProvider.future);
                          user = ref.refresh(getUserProvider);
                        },
                        child: data.followers!.contains(JwtDecoder.decode(
                                ref.watch(tokenProvider))['email'])
                            ? const Text('Unfollow')
                            : const Text('Follow'),
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
                ref.watch(getPostsProvider).when(
                  data: (data) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                    child: Column(
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
                                          style: const TextStyle(color: Colors.white),
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
        return const Text('Some error occurred');
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
