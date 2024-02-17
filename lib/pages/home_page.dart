import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/models/constants.dart';
import 'package:expense_manager/pages/add_room.dart';
import 'package:expense_manager/pages/request_page.dart';
import 'package:expense_manager/utils/login_manager.dart';
import 'package:expense_manager/widgets/rooms_list.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/smtp_server/sendgrid.dart';
import 'package:provider/provider.dart';
import 'package:mailer/mailer.dart' as email;

import '../widgets/account_popup.dart';
import '../widgets/popup_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  void _showToast(String text,bool isError) {
    String color = isError ? "#ff3333":"#4caf50";
    Fluttertoast.showToast(
      msg: text,
      backgroundColor: isError ? Colors.red : Colors.green,
      webBgColor: color,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 2,
    );
  }

  Future sendEmail(UserFeedback feedback) async {
    final smtpServer = sendgrid(
      'apikey',
      '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',
    );

    final screenshot = Stream.value(feedback.screenshot.toList());

    final message = email.Message()
      ..from = const email.Address(feedBackEmail, 'Expense Manager')
      ..recipients = ['s.shiddeshwaran@gmail.com', 'profession.ragul@gmail.com']
      ..subject = 'Feedback[Expense Manager]'
      ..text = feedback.text
      ..attachments = [
        email.StreamAttachment(
          screenshot,
          'image/png',
          fileName: 'screenshot.png',
        ),
      ];

    try {
      await email.send(message, smtpServer);
      _showToast('Thank you for your valuable feedback!', false);
    } catch (e) {
      _showToast('Error reporting your feedback!', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          centerTitle: true,
          title: const Text('Expense Manager'),
          leading: IconButton(
            onPressed: () {
              final provider =
                  Provider.of<LoginProvider>(context, listen: false);
              provider.logout();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          actions: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data!.data();
                    var photo = data!['profileImageUrl'] ?? defaultProfileImage;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AccountPopUp(
                              action: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 15),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RequestPage(),
                                        ),
                                      );
                                    },
                                    leading: const Icon(
                                      Icons.notifications,
                                      color: Colors.orangeAccent,
                                    ),
                                    title: const Text("Requests"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 15),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      BetterFeedback.of(context)
                                          .show((UserFeedback feedback) {
                                        sendEmail(feedback);
                                      });
                                    },
                                    leading: const Icon(
                                      Icons.bug_report_outlined,
                                      color: Colors.teal,
                                    ),
                                    title: const Text("send Feedback"),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(50),
                          foregroundImage: NetworkImage(photo),
                        ),
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: CircleAvatar(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }),
          ],
        ),
        body: const RoomsList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showBottomSheet();
          },
          child: const Icon(Icons.add),
        ));
  }

  _showBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: InkWell(
                      splashColor: Colors.grey,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddRoom(),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 15,
                        height: 40,
                        child: const Center(
                          child: Text(
                            "Create Room",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        await showDialog(
                          context: context,
                          builder: (context) => const PopUpDialog(),
                        );
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 15,
                        height: 40,
                        child: const Center(
                          child: Text(
                            "Join Room",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
