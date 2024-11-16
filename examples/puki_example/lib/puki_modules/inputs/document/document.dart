import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:puki/puki.dart';
import 'package:puki/puki_ui.dart';
import 'package:puki_example/config.dart';
import 'package:puki_example/puki_modules/services/firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DokumenInput {
  static bool get isFirestoreEmulator => Config.isDevMode;

  static PmInputType type = PmInputType(
    icon: MdiIcons.fileDocumentOutline,
    name: "Document",
    type: "document",
    preview: (context, content) {
      return SizedBox(
        height: 30,
        width: 30,
        child: Center(
          child: Text(
            content.customData!['extension'].toString().toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      );
    },
    onIconTap: (context, room) async => await _onIconTap(context, room),
    body: (context, content) => _body(context, content),
  );

  static Future<void> _onIconTap(BuildContext context, PmRoom room) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'rtf', 'xls', 'xlsx', 'csv', 'ppt', 'pptx', 'md'],
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.single.bytes;
      String fileName = result.files.single.name;
      String extension = result.files.single.extension!;

      String downloadUrl;

      if (kIsWeb) {
        final response = await FirebaseStorageService.webUpload(
          fileBytes!,
          fileName,
          null,
          isImage: false,
        );

        downloadUrl = response;
      } else {
        final response = await FirebaseStorageService.upload(
          file: File(result.files.single.path!),
          name: result.files.single.name,
          isImage: false,
        );
        downloadUrl = response;
      }

      final content = PmContent(
        type: type.type,
        message: type.name,
        customData: {"url": downloadUrl, "name": fileName, "extension": extension},
      );

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(height: 50, width: 50, child: Center(child: CircularProgressIndicator())),
          );
        },
      );

      await Future.delayed(Duration(seconds: 1));

      await PukiUi.sendCustomMessage(room: room, content: content);

      if (!context.mounted) return;

      Navigator.pop(context);
    }
  }

  static _body(BuildContext context, PmContent content) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Open file"),
              content: Text(content.customData!['name']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(
                        text: FirebaseStorageService.adjustImageUrlForPlatform(
                      url: content.customData!['url'],
                      isFirebaseEmulator: isFirestoreEmulator,
                    )));
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("URL copied"), duration: Duration(seconds: 1)),
                    );
                  },
                  child: Text("Copy Url"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    launchUrlString(
                        FirebaseStorageService.adjustImageUrlForPlatform(
                          url: content.customData!['url'],
                          isFirebaseEmulator: isFirestoreEmulator,
                        ),
                        mode: LaunchMode.externalApplication);
                  },
                  child: Text("Open"),
                )
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(type.icon, size: 14, color: Colors.blue),
          SizedBox(width: 2),
          Flexible(
            child: Text(
              content.customData!['name'],
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          )
        ],
      ),
    );
  }
}
