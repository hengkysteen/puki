// import 'package:flutter/material.dart';
// import 'package:puki/puki.dart';
// import 'package:puki/src/core/core.dart';

// class PukiUserList extends StatelessWidget {
//   final void Function(List<PmUser>? users)? onData;
//   final Widget Function(List<PmUser>? users)? builder;

//   const PukiUserList({super.key, this.builder, this.onData});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<PmUser>>(
//       future: PukiCore.firestore.user.getAllUsers(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return SizedBox();

//         final users = snapshot.data;

//         if (builder != null) return builder!(users);

//         if (onData != null) {
//           onData!(users);
//         }

//         if (users == null) return SizedBox();

//         return ListView.builder(
//           itemCount: users.length,
//           itemBuilder: (context, index) {
//             final user = users[index];
//             return ListTile(
//               title: Text(user.name),
//             );
//           },
//         );
//       },
//     );
//   }
// }
