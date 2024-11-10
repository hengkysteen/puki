import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String imageUrl;
  final String firstLetterAvatar;
  final double radius;
  final Color? backgroundColor;

  const CustomCircleAvatar({
    super.key,
    this.imageUrl = "",
    required this.firstLetterAvatar,
    this.radius = 20.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        TextStyle textStyle = _getTextStyle(context, theme);
        Color effectiveBackgroundColor = _getBackgroundColor(context, theme, textStyle.color);

        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0.2,
                blurRadius: 0.7,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarContent(context),
          ),
        );
      },
    );
  }

  // Fungsi untuk menentukan isi dari avatar: gambar atau huruf pertama
  Widget _buildAvatarContent(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, url, error) {
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          firstLetterAvatar.isNotEmpty ? firstLetterAvatar[0].toUpperCase() : '',
          style: _getTextStyle(context, Theme.of(context)),
        ),
      );
    }
  }

  // Fungsi untuk mendapatkan style teks
  TextStyle _getTextStyle(BuildContext context, ThemeData theme) {
    TextStyle textStyle = theme.primaryTextTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);

    if (theme.useMaterial3) {
      textStyle = textStyle.copyWith(color: theme.colorScheme.onPrimaryContainer);
    }
    return textStyle;
  }

  // Fungsi untuk mendapatkan warna latar belakang
  Color _getBackgroundColor(BuildContext context, ThemeData theme, Color? textColor) {
    Color? effectiveBackgroundColor = backgroundColor;

    if (effectiveBackgroundColor == null) {
      if (theme.useMaterial3) {
        effectiveBackgroundColor = theme.colorScheme.primaryContainer;
      } else {
        effectiveBackgroundColor = _getFallbackBackgroundColor(context, theme, textColor);
      }
    }
    return effectiveBackgroundColor;
  }

  // Fungsi untuk mendapatkan warna fallback background berdasarkan kecerahan
  Color _getFallbackBackgroundColor(BuildContext context, ThemeData theme, Color? textColor) {
    switch (ThemeData.estimateBrightnessForColor(textColor!)) {
      case Brightness.dark:
        return theme.primaryColorLight;
      case Brightness.light:
        return theme.primaryColorDark;
      default:
        return theme.primaryColorLight;
    }
  }
}
