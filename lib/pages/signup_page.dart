import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  String? emailError;
  String? passError;
  String? nameError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        centerTitle: true,
        title: const Text('Sign Up'),
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TextField(
              controller: username,
              decoration: InputDecoration(
                hintText: 'Enter UserName',
                errorText: nameError,
              ),
              keyboardType: TextInputType.name,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.newUsername
              ],
              onChanged: (text) {
                setState(() {
                  if (text.isNotEmpty) {
                    emailError = null;
                  } else {
                    emailError = 'Name can\'t be empty';
                  }
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TextField(
              controller: password,
              decoration: InputDecoration(
                hintText: 'Enter Password',
                errorText: passError,
              ),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              autofillHints: const [
                AutofillHints.password,
                AutofillHints.newPassword
              ],
              onChanged: (text) {
                setState(() {
                  if (text.isNotEmpty) {
                    emailError = null;
                  } else {
                    emailError = 'invalid password';
                  }
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
        ],
      ),
    );
  }
}
