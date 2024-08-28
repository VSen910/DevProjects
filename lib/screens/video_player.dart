import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projects_app/utilities/providers.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  const VideoPlayer({super.key});

  @override
  ConsumerState<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends ConsumerState<VideoPlayer> {
  late FlickManager flickManager;

  @override
  void dispose() {
    super.dispose();
    flickManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        ref.watch(selectedVideoProvider),
      ),
    );
    flickManager = FlickManager(
        videoPlayerController: videoPlayerController
    );

    // print('aspect ratio ${videoPlayerController.value.aspectRatio}');
    // print('height ${videoPlayerController.value.size.height}');
    return Center(
      child: AspectRatio(
        aspectRatio: 16/9,
        child: FlickVideoPlayer(flickManager: flickManager),
      ),
    );
  }
}
