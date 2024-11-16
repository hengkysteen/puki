class Db {
  // Private static instance of Db
  static final Db _instance = Db._internal();

  // Private constructor
  Db._internal();

  // Factory constructor to return the singleton instance
  factory Db() {
    return _instance;
  }

  static final List<Map<String, dynamic>> _users = [
    {
      "id": "1",
      "name": "Gildarts Clivex",
      "email": "gildartsclive@puki.com",
      "avatar": 'https://i.ibb.co.com/0hLhs05/gildart.jpg',
      "password": "123123",
    },
    {
      "id": '2',
      "name": "Juvia Lockser",
      "email": "juvialockser@puki.com",
      "avatar": 'https://i.ibb.co.com/M9531ff/juvia.jpg',
      "password": "123123",
    },
    {
      "id": '3',
      "name": "Erza Scarlet",
      "email": "erzascarlet@puki.com",
      "avatar": 'https://i.ibb.co.com/M953zff/erza.jpg',
      "password": "123123",
    },
    {
      "id": '4',
      "name": "Makarov Dreyar",
      "email": "makarovdreyar@puki.com",
      "avatar": 'https://i.ibb.co.com/BKw3ZYw/makarov.jpg',
      "password": "123123",
    },
    {
      "id": "5",
      "name": "Natsu Dragneel",
      "email": "natsudragneel@puki.com",
      "avatar": '',
      "password": "123123",
    },
    {
      "id": "6",
      "name": "Gray Fullbuster",
      "email": "grayfullbuster@puki.com",
      "avatar": 'https://i.ibb.co.com/L9yFjVC/gray.jpg',
      "password": "123123",
    },
    {
      "id": "7",
      "name": "Happy",
      "email": "happy@puki.com",
      "avatar": "",
      "password": "123123",
    }
  ];

  static List<Map<String, dynamic>> get users {
    _users.sort((a, b) => a['name'].compareTo(b['name']));
    return _users;
  }

  static Map<String, dynamic>? getById(String id) {
    return _users.firstWhere((user) => user['id'] == id);
  }

  static Map<String, dynamic>? getByEmail(String email) {
    return _users.firstWhere((user) => user['email'] == email);
  }
}
