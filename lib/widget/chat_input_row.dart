import 'package:chat_app/pages/chat_page.dart';
import 'package:flutter/material.dart';

class ChatInputRow extends StatefulWidget {
  final ChatController controller;
  const ChatInputRow({required this.controller, Key? key}) : super(key: key);

  @override
  State<ChatInputRow> createState() => _ChatInputRowState();
}

class _ChatInputRowState extends State<ChatInputRow> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          // color: Colors.red,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15)),
        ),
        child: Row(children: [
          Container(
            height: 56,
            child: PopupMenuButton(
              onSelected: widget.controller.onAddPopupMenuButtonSelected,
              itemBuilder: (context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                      value: "file", child: Text("ارسال فایل")),
                  PopupMenuItem<String>(
                      value: "image", child: Text("ارسال تصویر")),
                  PopupMenuItem<String>(
                      value: "camera", child: Text("بازکردن دوربین"))
                ];
              },
            ),

            //     PopupMenuButton(
            //   icon: const Icon(Icons.add_outlined),
            //   onSelected: widget.controller.onAddPopupMenuButtonSelected,
            //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            //     const PopupMenuItem<String>(
            //         value: "file",
            //         child: ListTile(
            //           leading: CircleAvatar(
            //             backgroundColor: Colors.green,
            //             foregroundColor: Colors.white,
            //             child: Icon(Icons.attachment_outlined),
            //           ),
            //           title: Text("ارسال فایل"),
            //           contentPadding: EdgeInsets.all(0),
            //         )),
            //     const PopupMenuItem<String>(
            //       value: 'image',
            //       child: ListTile(
            //         leading: CircleAvatar(
            //           backgroundColor: Colors.blue,
            //           foregroundColor: Colors.white,
            //           child: Icon(Icons.image_outlined),
            //         ),
            //         title: Text(
            //           "ارسال عکس",
            //           style: TextStyle(fontSize: 16),
            //         ),
            //         contentPadding: EdgeInsets.all(0),
            //       ),
            //     ),
            //   ],
            // ),

            //
          ),
          Expanded(
              child: TextField(
            controller: widget.controller.sendController,
            decoration: InputDecoration(
                hintText: "نوشتن پیام", border: InputBorder.none),
          )),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              widget.controller.sendController.text.isEmpty
                  ? null
                  : widget.controller.send();
              setState(() {});
            },
          )
        ]),
        // child: Row(
        //   children: [
        //     Container(
        //       height: 56,
        //       decoration: BoxDecoration(
        //            color: Colors.red,
        //           borderRadius: BorderRadius.only(
        //               bottomLeft: Radius.circular(12),
        //               bottomRight: Radius.circular(12))),
        //     )
        //   ],
        // ),
      ),
    );
  }
}








// class ChatInputRow extends StatefulWidget {
//   final ChatController controller;

//   const ChatInputRow(this.controller, {Key? key}) : super(key: key);

//   @override
//   State<ChatInputRow> createState() => _ChatInputRowState();
// }

// class _ChatInputRowState extends State<ChatInputRow> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       textDirection: TextDirection.ltr,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Container(
//           height: 56,
//           // width: widget.controller.inputText.isEmpty ? 56 : 0,
//           alignment: Alignment.center,
//           clipBehavior: Clip.hardEdge,
//           decoration: const BoxDecoration(),
//           child: PopupMenuButton(
//               icon: const Icon(Icons.add_outlined),
//               onSelected: widget.controller.onAddPopupMenuButtonSelected,
//               itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                     const PopupMenuItem<String>(
//                         value: "file",
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundColor: Colors.green,
//                             foregroundColor: Colors.white,
//                             child: Icon(Icons.attachment_outlined),
//                           ),
//                           title: Text("ارسال فایل"),
//                           contentPadding: EdgeInsets.all(0),
//                         )),
//                     const PopupMenuItem<String>(
//                       value: 'image',
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           child: Icon(Icons.image_outlined),
//                         ),
//                         title: Text(
//                           "ارسال عکس",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                         contentPadding: EdgeInsets.all(0),
//                       ),
//                     ),
//                   ]),
//         ),
//         Expanded(
//             child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: TextField(
//             maxLines: 8,
//             minLines: 1,
//             controller: widget.controller.sendController,
//             autofocus: true,
//             style: const TextStyle(fontSize: 16),
//             decoration: const InputDecoration(
//                 hintText: 'نوشتن پیام',
//                 hintStyle: TextStyle(fontSize: 16),
//                 border: InputBorder.none),
//           ),
//         )),
//         IconButton(
//           splashRadius: 30,
//             icon: const Icon(Icons.send_outlined),
//             onPressed: () {
//               widget.controller.sendController.text.isEmpty
//                   ? null
//                   : widget.controller.send();
//               setState(() {});
//             }),
//       ],

//       //  widget.controller.selectMode
//       //     ? [
//       //         widget.controller.selectedEvents.length == 1
//       //             ? widget.controller.selectedEvents.first
//       //                     .getDisplayEvent(widget.controller.timeline)
//       //                     .status
//       //                     .isSent
//       //                 ? SizedBox(
//       //                     height: 56,
//       //                     child: TextButton(
//       //                         onPressed: widget.controller.replyAction,
//       //                         child: Row(
//       //                           children: [
//       //                             Text("reply"),
//       //                             Icon(Icons.keyboard_arrow_right)
//       //                           ],
//       //                         )),
//       //                   )
//       //                 : SizedBox(
//       //                     height: 56,
//       //                     child: TextButton(
//       //                         onPressed: () {},
//       //                         child: Row(
//       //                           children: [Icon(Icons.send_outlined)],
//       //                         )),
//       //                   )
//       //             : SizedBox()
//       //       ]
//       //     : [
//       //         Container(
//       //           height: 56,
//       //           // width: widget.controller.inputText.isEmpty ? 56 : 0,
//       //           alignment: Alignment.center,
//       //           clipBehavior: Clip.hardEdge,
//       //           decoration: const BoxDecoration(),
//       //           child: PopupMenuButton(
//       //               icon: const Icon(Icons.add_outlined),
//       //               onSelected: widget.controller.onAddPopupMenuButtonSelected,
//       //               itemBuilder: (BuildContext context) =>
//       //                   <PopupMenuEntry<String>>[
//       //                     const PopupMenuItem<String>(
//       //                         value: "file",
//       //                         child: ListTile(
//       //                           leading: CircleAvatar(
//       //                             backgroundColor: Colors.green,
//       //                             foregroundColor: Colors.white,
//       //                             child: Icon(Icons.attachment_outlined),
//       //                           ),
//       //                           title: Text("Send file"),
//       //                           contentPadding: EdgeInsets.all(0),
//       //                         )),
//       //                     const PopupMenuItem<String>(
//       //                       value: 'image',
//       //                       child: ListTile(
//       //                         leading: CircleAvatar(
//       //                           backgroundColor: Colors.blue,
//       //                           foregroundColor: Colors.white,
//       //                           child: Icon(Icons.image_outlined),
//       //                         ),
//       //                         title: Text(
//       //                           "Send image",
//       //                           style: TextStyle(fontSize: 16),
//       //                         ),
//       //                         contentPadding: EdgeInsets.all(0),
//       //                       ),
//       //                     ),
//       //                   ]),
//       //         ),
//       //         Expanded(
//       //             child: TextField(
//       //           controller: widget.controller.sendController,
//       //           decoration: const InputDecoration(
//       //               hintText: 'Send message',
//       //               hintStyle: TextStyle(fontSize: 16),
//       //               border: InputBorder.none),
//       //         )),
//       //         IconButton(
//       //             icon: const Icon(Icons.send_outlined),
//       //             onPressed: () {
//       //               widget.controller.sendController.text.isEmpty
//       //                   ? null
//       //                   : widget.controller.send();
//       //               setState(() {});
//       //             }),
//       //       ],
//     );
//   }
// }
