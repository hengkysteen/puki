import 'package:puki/puki.dart';
import 'camera/photo/photo.dart';
import 'document/document.dart';
import 'stickers/stikers.dart';

class PukiModule {
  static List<PmInputType> inputs = [
    PukiInputStickers.type,
    DokumenInput.type,
    InputCameraPhoto.type,
  ];
}
