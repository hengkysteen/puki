import 'package:puki/puki.dart';

void validateCurrentUser() {
  if (Puki.user.currentUser == null) throw Exception("Please call Puki.user.setup before use this widget");
}
