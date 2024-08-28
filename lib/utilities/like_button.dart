import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projects_app/utilities/providers.dart';

class LikeButton extends ConsumerWidget {
  const LikeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(isLikedProvider);
    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.white,
      ),
      onPressed: () async {
        ref.read(isLikedProvider.notifier).update((state) => !state);
        // final res = await ref.watch(likePostProvider.future);
        await ref.refresh(likePostProvider.future);
        await ref.refresh(selectedPostProvider.future);
        // print(res);
        print('nhi aaya');
      },
    );
  }
}
