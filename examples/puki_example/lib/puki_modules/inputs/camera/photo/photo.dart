import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puki/puki.dart';
import 'package:puki/puki_ui.dart';
import 'package:puki_example/puki_modules/services/firebase_storage/firebase_storage.dart';
import 'package:puki_example/services/image_cache.dart';

import 'photo_preview.dart';

class InputCameraPhoto {
  static final ImagePicker _picker = ImagePicker();

  static PmReply? replayToMessage;

  static PmInputType type = PmInputType(
    icon: MdiIcons.imageOutline,
    name: "Photo",
    type: "photo",
    preview: (context, content) {
      return Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
            image: ImageCached.networkProvider(FirebaseStorageService.adjustImageUrlForPlatform(url: content.customData!['url'])),
            fit: BoxFit.cover,
          ),
        ),
      );
    },
    onIconTap: (context, room) async {
      if (kIsWeb) {
        await _pickImage(context, ImageSource.gallery, room);
      } else {
        await _imageSourceChooser(context, room, type);
      }
    },
    body: (context, content) {
      return GestureDetector(
        onTap: () {
          _showFullPhoto(context, content);
        },
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageCached.network(FirebaseStorageService.adjustImageUrlForPlatform(url: content.customData!['url'])),
              Visibility(
                visible: (content.customData!['caption'] as String).isNotEmpty,
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    content.customData!['caption'],
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );

  static void _showFullPhoto(BuildContext context, PmContent content) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        color: Colors.black,
        child: Center(
          child: ImageCached.network(FirebaseStorageService.adjustImageUrlForPlatform(url: content.customData!['url'])),
        ),
      ),
    );
  }

  static Future<void> _bottomSheetWithList({required BuildContext context, required List<Widget> children}) async {
    return await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(10),
          child: Material(
            borderRadius: BorderRadius.circular(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        );
      },
    );
  }

  static Future<void> _pickImage(BuildContext context, ImageSource imageSource, PmRoom room) async {
    XFile? file = await _picker.pickImage(source: imageSource);

    if (file == null) return;

    if (!context.mounted) return;

    _previewImage(context, file, room, type);
  }

  static Future<void> _imageSourceChooser(BuildContext context, PmRoom room, PmInputType type) async {
    await _bottomSheetWithList(
      context: context,
      children: [
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          title: Text("Camera"),
          leading: Icon(MdiIcons.camera),
          onTap: () async {
            await _pickImage(context, ImageSource.camera, room);
          },
        ),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
          title: Text("Gallery"),
          leading: Icon(MdiIcons.album),
          onTap: () async {
            await _pickImage(context, ImageSource.gallery, room);
          },
        ),
      ],
    );
  }

  static Future<void> _previewImage(BuildContext context, XFile image, PmRoom room, PmInputType type) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (_) => InputCameraPhotoPreview(
        inputType: type,
        file: image,
        room: room,
        onSend: (caption) async {
          await uploadToStorage(context, image, room, type, caption: caption);
          if (!context.mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  static Future<void> uploadToStorage(BuildContext context, XFile image, PmRoom room, PmInputType type, {String caption = ""}) async {
    late String imageUrl;

    try {
      if (kIsWeb) {
        Uint8List imageData = await image.readAsBytes();
        final data = await FirebaseStorageService.webUpload(imageData, image.name, image.mimeType!);
        imageUrl = data;
      } else {
        final File imageData = File(image.path);
        final data = await FirebaseStorageService.upload(file: imageData, name: image.name);
        imageUrl = data;
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(e.toString()),
          );
        },
      );

      rethrow;
    }

    final content = PmContent(
      type: type.type,
      message: type.type,
      customData: {"url": imageUrl, "caption": caption},
    );

    if (!context.mounted) return;

    PukiUi.sendCustomMessage(room: room, content: content, onMessageSended: (_) {});
    Navigator.pop(context);
  }
}
