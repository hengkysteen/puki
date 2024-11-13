import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puki/puki.dart';

class InputCameraPhotoPreview extends StatefulWidget {
  final PmInputType inputType;
  final XFile file;
  final PmRoom room;
  final Future<void> Function(String caption) onSend;
  const InputCameraPhotoPreview({super.key, required this.inputType, required this.file, required this.room, required this.onSend});
  @override
  State<InputCameraPhotoPreview> createState() => _InputCameraPhotoPreviewState();
}

class _InputCameraPhotoPreviewState extends State<InputCameraPhotoPreview> {
  TextEditingController captionCtrl = TextEditingController();
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: Container(child: kIsWeb ? Image.network(widget.file.path) : Image.file(File(widget.file.path))),
          ),
          Padding(
            // padding: EdgeInsets.only(top: MediaQueryData.fromView(WidgetsBinding.instance.window).padding.top),
            padding: EdgeInsets.only(top: View.of(context).padding.top),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ),
              body: Column(
                children: [
                  Spacer(),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                              child: TextField(
                                controller: captionCtrl,
                                decoration: InputDecoration(isDense: true, hintText: 'Captions', border: InputBorder.none),
                                autofocus: false,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          height: 45,
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            onPressed: isSending
                                ? null
                                : () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: SizedBox(height: 50, width: 50, child: Center(child: CircularProgressIndicator())),
                                        );
                                      },
                                    );
                                    await widget.onSend(captionCtrl.text);
                                    captionCtrl.clear();
                                    if (!context.mounted) return;

                                    Navigator.pop(context);
                                  },
                            child: Icon(Icons.send),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
