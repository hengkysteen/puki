// coverage:ignore-file
class F {
  static const String ROOM_ID = 'room_id';
  static const String DATE = 'date';
  static const String MESSAGES = 'messages';
  static const String VISIBLE_TO = 'visible_to';
  static const String STATUS = 'status';
  static const String READ_BY = 'read_by';
  static const String LAST_MESSAGE = 'last_message';
  static const String USERS = 'users';
  static const String TIME = 'time';
  static const String PRIVATE = 'private';
  static const String GROUP = 'group';
  static const String UNREAD = 'unread';

  static const String GROUP_UNREAD = '$GROUP.$UNREAD';
  static const String PRIVATE_UNREAD = '$PRIVATE.$UNREAD';
  static const String FIRESTORE_COLLECTION_PREFIX = 'puki_';
}
