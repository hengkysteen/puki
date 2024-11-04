import 'package:puki/src/core/settings/settings.dart';

abstract class BaseCollection {
  BaseCollection();

  PukiSettings get settings => PukiSettings.instance;
}
