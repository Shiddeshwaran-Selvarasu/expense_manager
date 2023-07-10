import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';

import '../utils/login_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.random, Key? key}) : super(key: key);

  final int random;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String? emailError;
  String? passError;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Expense Manager'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              child: Image.asset('assets/images/${widget.random}.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
            child: TextField(
              controller: email,
              decoration: InputDecoration(
                hintText: 'Enter Email',
                errorText: emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.newUsername
              ],
              onChanged: (text) {
                setState(() {
                  if (EmailValidator.validate(text)) {
                    emailError = null;
                  } else {
                    emailError = 'Enter a Valid Email';
                  }
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
            child: TextField(
              controller: password,
              decoration: InputDecoration(
                hintText: 'Enter password',
                errorText: passError,
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              autofillHints: const [
                AutofillHints.password,
                AutofillHints.newPassword
              ],
              onChanged: (text) {
                setState(() {
                  if (text.length >= 8) {
                    passError = null;
                  } else {
                    passError = 'Enter At least 8 characters';
                  }
                });
              },
              keyboardType: TextInputType.visiblePassword,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text('Create account'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 90,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  if ((emailError == null || email.value.text == '') &&
                      (passError == null || password.value.text == '')) {
                    provider.login(email.value.text, password.value.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                child: const Text('Login'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
