import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:projects_app/screens/create_post_page.dart';
import 'package:projects_app/screens/logged_user_page.dart';
import 'package:projects_app/screens/post_page.dart';
import 'package:projects_app/screens/search_page.dart';
import 'package:projects_app/utilities/providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
        var feed = ref.watch(feedProvider);
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade900,
            title: Text(
              'DevProjects',
              style: GoogleFonts.montserrat(
                color: Colors.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  ref.read(selectedUserEmailProvider.notifier).state =
                      data.email;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoggedUserPage(),
                    ),
                  );
                },
                child: Ink(
                  child: Container(
                    height: 45,
                    width: 45,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Image.network(data!.picturePath!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: LiquidPullToRefresh(
            onRefresh: () async {
              feed = ref.refresh(feedProvider);
            },
            child: feed.when(
              data: (data) {
                final list = data;
                if (list == null) {
                  return const Text('list is null');
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final post = list[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          splashColor: Colors.white,
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            ref.read(selectedPostIdProvider.notifier).state =
                                post.postId;
                            ref.read(isLikedProvider.notifier).state =
                                await isLikedFn();
                            navigator.push(
                              MaterialPageRoute(
                                builder: (context) => const PostPage(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                style: BorderStyle.none,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey.shade800,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 45,
                                      width: 45,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Image.network(post.picturePath),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.name,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          post.title,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, st) {
                print(error);
                print(st);
                return const Text('Something went wrong');
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.yellow,
            onPressed: () {
              ref.read(screenshotsProvider.notifier).state = [];
              ref.read(recordingsProvider.notifier).state = [];
              ref.read(recordingsThumbnailProvider.notifier).state = [];
              ref.read(postTitleProvider.notifier).state = '';
              ref.read(postDescProvider.notifier).state = '';
              ref.read(postGithubProvider.notifier).state = '';
              ref.read(postDeployedProvider.notifier).state = '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
      error: (error, st) {
        return const Center(
          child: Text('Some error occurred'),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
