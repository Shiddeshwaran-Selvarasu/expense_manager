import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/about_page.dart';

class AccountPopUp extends StatefulWidget {
  const AccountPopUp({Key? key, required this.action}) : super(key: key);

  final List<Widget> action;

  @override
  _AccountPopUpState createState() => _AccountPopUpState();
}

class _AccountPopUpState extends State<AccountPopUp> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: ListTile(
                  onTap: () {},
                  leading: CircleAvatar(
                    foregroundImage: NetworkImage(user?.photoURL ?? ''),
                  ),
                  title: Text(
                    user!.displayName!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(user!.email!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const Divider(
                thickness: 1.2,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                  leading: const Icon(
                    Icons.info_rounded,
                    color: Colors.blue,
                  ),
                  title: const Text("Expense Manager"),
                ),
              ),
              Wrap(
                children: widget.action,
              ),
              const Divider(
                thickness: 1.2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      launch('https://pcdev.tech');
                    },
                    child: const Text("pcdev.tech",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(
                    width: 25,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 5.0,
                        width: 5.0,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const Text("Expense Manager",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
