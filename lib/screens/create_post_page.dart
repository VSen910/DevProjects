import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects_app/models/post.dart';
import 'package:projects_app/utilities/providers.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreatePostPage extends ConsumerWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picker = ImagePicker();
    final formKey = GlobalKey<FormState>();

    final title = ref.watch(postTitleProvider);
    final description = ref.watch(postDescProvider);
    final github = ref.watch(postGithubProvider);
    final deployedLink = ref.watch(postDeployedProvider);
    final screenshots = ref.watch(screenshotsProvider);
    final recordings = ref.watch(recordingsProvider);
    final recordingsThumbnails = ref.watch(recordingsThumbnailProvider);

    final titleController = TextEditingController(text: title);
    final descriptionController = TextEditingController(text: description);
    final githubController = TextEditingController(text: github);
    final deployedLinkController = TextEditingController(text: deployedLink);

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: const Text('Create a post'),
        actions: [
          IconButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();

                final cloudinary = CloudinaryPublic(
                  dotenv.env['CLOUDINARY_CLOUD_NAME']!,
                  dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
                );
                final resImages = await cloudinary.uploadFiles(screenshots
                    .map((e) => CloudinaryFile.fromFile(e.path,
                        resourceType: CloudinaryResourceType.Image))
                    .toList());

                final resVids = await cloudinary.uploadFiles(recordings
                    .map((e) => CloudinaryFile.fromFile(e.path,
                        resourceType: CloudinaryResourceType.Video))
                    .toList());

                final imageUrls = resImages.map((e) => e.secureUrl).toList();
                final videoUrls = resVids.map((e) => e.secureUrl).toList();

                ref.read(createdPostProvider.notifier).state = Post(
                  description: description,
                  github: github,
                  deployedLink: deployedLink,
                  recordings: videoUrls,
                  screenshots: imageUrls,
                  title: title,
                );

                final res = await ref.watch(createPostProvider.future);
                if (res) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post created successfully!'),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Some error occured'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(
              Icons.check,
              color: Colors.yellow,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        onSaved: (val) {
                          ref.read(postTitleProvider.notifier).state = val!;
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle:
                              TextStyle(color: Colors.yellow.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.yellow.shade400),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: descriptionController,
                        style: const TextStyle(color: Colors.white),
                        minLines: 8,
                        maxLines: 8,
                        onSaved: (val) {
                          ref.read(postDescProvider.notifier).state = val!;
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'Description',
                          floatingLabelStyle:
                              TextStyle(color: Colors.yellow.shade400),
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.yellow.shade400),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: githubController,
                        style: const TextStyle(color: Colors.white),
                        onSaved: (val) {
                          ref.read(postGithubProvider.notifier).state = val!;
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Github link is required';
                          }
                          final uri = Uri.parse(val);
                          if (uri.scheme == 'https' &&
                              uri.host == 'github.com' &&
                              uri.path.isNotEmpty) {
                            return null;
                          }
                          return 'Invalid link';
                        },
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'Github link',
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle:
                              TextStyle(color: Colors.yellow.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.yellow.shade400),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: deployedLinkController,
                        style: const TextStyle(color: Colors.white),
                        onSaved: (val) {
                          ref.read(postDeployedProvider.notifier).state = val!;
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return null;
                          }
                          final uri = Uri.parse(val);
                          if (uri.host.isEmpty) {
                            return 'Invalid Url';
                          }
                          return null;
                        },
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'Deployed link',
                          labelStyle: const TextStyle(color: Colors.grey),
                          floatingLabelStyle:
                              TextStyle(color: Colors.yellow.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.yellow.shade400),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Screenshots',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () async {
                                formKey.currentState!.save();
                                final list = await picker.pickMultiImage();
                                ref
                                    .read(screenshotsProvider.notifier)
                                    .update((state) => state + list);
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: screenshots.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.file(
                                    File(screenshots[index].path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recordings',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () async {
                                formKey.currentState!.save();
                                final video = await picker.pickVideo(
                                    source: ImageSource.gallery);
                                if (video != null) {
                                  ref
                                      .read(recordingsProvider.notifier)
                                      .state
                                      .add(video);
                                  final thumbnail =
                                      await VideoThumbnail.thumbnailData(
                                          video: video.path);
                                  ref
                                      .read(
                                          recordingsThumbnailProvider.notifier)
                                      .update(
                                          (state) => [...state, thumbnail!]);
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recordingsThumbnails.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Image.memory(
                                    recordingsThumbnails[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
