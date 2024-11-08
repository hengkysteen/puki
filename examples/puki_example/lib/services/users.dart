class Users {
  static Map<String, dynamic>? currentUser;

  static void setCurrentUser(Map<String, dynamic> user) {
    currentUser = user;
  }

  static List<Map<String, dynamic>> dummy = [
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
      "avatar": 'https://drive.google.com/uc?export=download&id=1PKAsORqs9e3gbKOtmYTJgFPFyAY3yHjN',
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
}
