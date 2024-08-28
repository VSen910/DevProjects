import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projects_app/screens/video_player.dart';
import 'package:projects_app/utilities/like_button.dart';
import 'package:projects_app/utilities/providers.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({super.key});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  @override
  Widget build(BuildContext context) {
    final post = ref.watch(selectedPostProvider);
    final commentController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: const Text('Posts'),
      ),
      body: post.when(
        data: (post) {
          final github = post!.github;
          final deployedLink = post.deployedLink;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 8),
                      Text(
                        post.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text(
                            '🔗',
                            style: TextStyle(fontSize: 36),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Link(
                                  uri: Uri.parse(github),
                                  target: LinkTarget.defaultTarget,
                                  builder: (context, openLink) {
                                    return TextButton(
                                      onPressed: () async {
                                        final uri = Uri.parse(github);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('Failed to open'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        post.github,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (post.deployedLink.isNotEmpty)
                                  Link(
                                    uri: Uri.parse(deployedLink),
                                    target: LinkTarget.defaultTarget,
                                    builder: (context, openLink) {
                                      return TextButton(
                                        onPressed: () async {
                                          final uri = Uri.parse(deployedLink);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text('Failed to open'),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          post.deployedLink,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.description,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Screenshots',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  CarouselSlider(
                    options: CarouselOptions(height: 200),
                    items: post.screenshots.map((e) {
                      return Builder(builder: (context) {
                        return InkWell(
                          onTap: () {
                            showImageViewer(context, Image.network(e).image);
                          },
                          child: Ink(
                            child: Container(
                              color: Colors.grey.shade800,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image.network(e),
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Recordings',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  CarouselSlider(
                    options: CarouselOptions(height: 200),
                    items: post.recordings.map((e) {
                      return FutureBuilder(
                          future: VideoThumbnail.thumbnailData(video: e),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return InkWell(
                                onTap: () {
                                  ref
                                      .read(selectedVideoProvider.notifier)
                                      .state = e;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const VideoPlayer(),
                                    ),
                                  );
                                },
                                child: Ink(
                                  child: Container(
                                    color: Colors.grey.shade800,
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Image.memory(snapshot.data!),
                                  ),
                                ),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          });
                    }).toList(),
                  ),
                  Row(
                    children: [
                      const LikeButton(),
                      Text(
                        post.likedBy.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      IconButton(
                        color: Colors.white,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            backgroundColor: Colors.grey.shade900,
                            builder: (context) {
                              return Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      'Comments',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: TextFormField(
                                      controller: commentController,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          onPressed: () async {
                                            final navigator =
                                                Navigator.of(context);
                                            final comment =
                                                commentController.text;
                                            if (comment.isNotEmpty) {
                                              ref
                                                  .read(
                                                      commentProvider.notifier)
                                                  .state = comment;
                                              await ref.watch(
                                                  addCommentProvider.future);
                                              await ref.refresh(
                                                  selectedPostProvider.future);
                                              navigator.pop();
                                            }
                                          },
                                          icon: Icon(
                                            Icons.send_rounded,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        hintText: 'Add a comment',
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: post.comments.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 45,
                                                  width: 45,
                                                  clipBehavior: Clip.hardEdge,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: Image.network(
                                                      post.comments[index]
                                                          ['picturePath']),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        post.comments[index]
                                                            ['name'],
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        post.comments[index]
                                                            ['comment'],
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                      ),
                      Text(
                        post.comments.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        error: (e, st) {
          print(e);
          print(st);
          return const Text('Some error occured');
        },
        loading: () {
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
