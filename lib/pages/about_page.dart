import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          "Expanse Manager",
          style: TextStyle(
            color: brightness == Brightness.light ? Colors.black : Colors.white,
          ),
        ),
        backgroundColor:
        brightness == Brightness.dark ? Colors.black26 : Colors.white,
        leading: IconButton(
          color: brightness == Brightness.light ? Colors.black : Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: Image.asset('assets/dash.png'),
      ),
    );
  }
}
