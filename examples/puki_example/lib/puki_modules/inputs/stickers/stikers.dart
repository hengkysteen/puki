import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:puki/puki.dart';
import 'package:puki_example/widgets/image_cache.dart';

class PukiInputStickers {
  static PmInputType type = PmInputType(
    insideBubble: false,
    icon: MdiIcons.emoticonCoolOutline,
    name: "Sticker",
    type: "sticker",
    preview: (_, content) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey[300]!),
          image: DecorationImage(
            image: ImageCached.networkProvider(content.customData!['url']),
            fit: BoxFit.cover,
          ),
        ),
      );
    },
    onIconTap: (context, room) {
      showModalBottomSheet(
        context: context,
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Stickers"),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: GridView.builder(
              primary: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
              itemCount: _stikersUrl.length,
              itemBuilder: (c, i) {
                return Container(
                  margin: EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      final content = PmContent(type: type.type, message: type.name, customData: {"url": _stikersUrl[i]});
                      Puki.sendCustomMessage(room: room, content: content);
                    },
                    child: Center(child: ImageCached.network(_stikersUrl[i])),
                  ),
                );
              },
            ),
          );
        },
      );
    },
    body: (_, content) => SizedBox(height: 65, width: 65, child: ImageCached.network(content.customData!['url'])),
  );

  static const _stikersUrl = [
    'https://i.ibb.co.com/F4cd7bz/1.webp',
    'https://i.ibb.co.com/N3Lst3K/3.webp',
    'https://i.ibb.co.com/8D83PWs/4.webp',
    'https://i.ibb.co.com/WxKkv4x/2.webp',
    'https://i.ibb.co.com/xJtgyQX/5.webp',
    'https://i.ibb.co.com/Ksgqt7F/6.webp',
    'https://i.ibb.co.com/7VgRW6g/7.webp',
    'https://i.ibb.co.com/dJxQk9F/8.webp',
    'https://i.ibb.co.com/DWG8Zv8/9.webp',
    'https://i.ibb.co.com/x6yQb17/10.webp',
    'https://i.ibb.co.com/LRfw8RD/11.webp',
    'https://i.ibb.co.com/5sFNJ6c/12.webp',
    'https://i.ibb.co.com/YTFWbbQ/13.webp',
    'https://i.ibb.co.com/BcQSRgz/15.webp',
    'https://i.ibb.co.com/QNjTZPy/14.webp',
    'https://i.ibb.co.com/hsY00pY/16.webp',
  ];
}
