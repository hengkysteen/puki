// coverage:ignore-file

abstract class PmCreateRoom {}

class PmCreateGroupRoom implements PmCreateRoom {
  final String name;
  final String createdBy;
  final List<String> members;
  final String logo;
  PmCreateGroupRoom({required this.name, required this.createdBy, required this.members, this.logo = ''});
}

class PmCreatePrivateRoom implements PmCreateRoom {
  final String receiver;
  PmCreatePrivateRoom({required this.receiver});
}
