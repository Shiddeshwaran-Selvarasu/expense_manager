import 'package:expense_manager/models/chat.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  const MessageTile({super.key, required this.messageId});

  final String messageId;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.only(
      //     top: 8,
      //     bottom: 8,
      //     left: list['sender'] == user!.uid ? 0 : 10,
      //     right: list['sender'] == user!.uid ? 10 : 0),
      // alignment: list['sender'] == user!.uid
      //     ? Alignment.centerRight
      //     : Alignment.centerLeft,
      // child: Container(
      //   margin: list['sender'] == user!.uid
      //       ? EdgeInsets.only(left: 30)
      //       : EdgeInsets.only(right: 30),
      //   padding: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: list['sender'] == user!.uid
      //           ? [Colors.white, Colors.white]
      //           : [Color(0xFF7DE38E), Color(0xFF7DE38E)],
      //     ),
      //     borderRadius: list['sender'] == user!.uid
      //         ? BorderRadius.only(
      //       bottomLeft: Radius.circular(15),
      //       topLeft: Radius.circular(15),
      //       topRight: Radius.circular(15),
      //     )
      //         : BorderRadius.only(
      //       bottomRight: Radius.circular(15),
      //       topLeft: Radius.circular(15),
      //       topRight: Radius.circular(15),
      //     ),
      //   ),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     crossAxisAlignment: list['sender'] == user!.uid
      //         ? CrossAxisAlignment.end
      //         : CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         list['message'],
      //         style: TextStyle(
      //           color: Colors.black,
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      //         child: Row(
      //           mainAxisSize: MainAxisSize.min,
      //           mainAxisAlignment: MainAxisAlignment.end,
      //           children: [
      //             Text(
      //               DateFormat('jm').format(list['Time'].toDate()),
      //               style: TextStyle(
      //                 color: Colors.grey,
      //                 fontSize: 10,
      //               ),
      //             ),
      //             SizedBox(
      //               width: 3,
      //             ),
      //             Icon(
      //               Icons.done_all_rounded,
      //               size: 13,
      //               color: Colors.blue,
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}