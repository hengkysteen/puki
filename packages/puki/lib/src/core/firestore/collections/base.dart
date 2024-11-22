import 'package:puki/src/core/core.dart';
import 'package:puki/src/core/settings/settings.dart';

abstract class BaseCollection {
  BaseCollection();

  PukiCoreSettings get settings => PukiCore.settings;
}
