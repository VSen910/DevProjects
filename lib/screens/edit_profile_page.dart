import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects_app/utilities/providers.dart';

class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(loggedUserProvider);
    final picker = ImagePicker();
    final cropper = ImageCropper();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      body: user.when(
        data: (data) {
          final nameController = TextEditingController(text: data!.name!);
          return Column(
            children: [
              InkWell(
                onTap: () async {
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    final croppedImage = await cropper.cropImage(
                      sourcePath: image.path,
                      uiSettings: [
                        AndroidUiSettings(
                          aspectRatioPresets: [CropAspectRatioPreset.square],
                          initAspectRatio: CropAspectRatioPreset.square,
                        ),
                      ],
                    );
                    ref.read(newProfilePicProvider.notifier).state =
                        croppedImage;
                  }
                },
                child: Ink(
                  child: Container(
                    height: 180,
                    width: 180,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(140),
                    ),
                    child: ref.watch(newProfilePicProvider) == null
                        ? Image.network(data.picturePath!)
                        : Image.file(
                            File(ref.watch(newProfilePicProvider)!.path),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      ref.read(newNameProvider.notifier).state = val!;
                    },
                    onTapOutside: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      final image = ref.watch(newProfilePicProvider);
                      if (image != null) {
                        final cloudinary = CloudinaryPublic(
                          dotenv.env['CLOUDINARY_CLOUD_NAME']!,
                          dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
                        );
                        final res = await cloudinary.uploadFile(
                          CloudinaryFile.fromFile(
                            image.path,
                            resourceType: CloudinaryResourceType.Image,
                          ),
                        );
                        ref.watch(newProfilePicUrlProvider.notifier).state =
                            res.secureUrl;
                      }
                      if (await ref.watch(updateUserProvider.future)) {
                        await ref.refresh(loggedUserProvider.future);
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
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
      ),
    );
  }
}
