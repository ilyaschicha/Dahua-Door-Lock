import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_auth/http_auth.dart' as http_auth;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  MaterialColor buildMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Door Lock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: buildMaterialColor(const Color(0xFF65C8C3)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool state = false;
  String responde = "";
  void _openDoor() async {
    try {
      var params = {
        'action': 'openDoor',
        'channel': '1',
        'UserID': '101',
        'Type': 'Remote',
      };
      var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');
      var client = http_auth.DigestAuthClient('admin', 'admin');
      var res = await client.get(
        Uri.parse('http://192.168.1.2/cgi-bin/accessControl.cgi?$query'),
      );
      if (res.statusCode != 200) {
        throw Exception('http.get error: statusCode= ${res.statusCode}');
      }
      setState(() {
        responde = res.body.replaceAll("\n", " ");
        state = responde.toLowerCase().contains("ok") ? true : false;
      });
    } on IOException catch (e) {
      debugPrint(e.toString());
    }
  }

// 202.81 1.64 36deg
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF65C8C3),
            Color(0xFF3BBD73),
          ],
        )),
        child: Center(
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .60,
                  height: MediaQuery.of(context).size.width * .60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500),
                    color: Colors.white.withOpacity(.2),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .35,
                  height: MediaQuery.of(context).size.width * .35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500),
                    color: Colors.white.withOpacity(.7),
                  ),
                  child: IconButton(
                    iconSize: MediaQuery.of(context).size.width * .20,
                    onPressed: _openDoor,
                    icon: Icon(
                      state ? Icons.lock_open : Icons.lock_outline,
                      color: const Color(0xFF65C8C3),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Column(
                        children: [
                          Text(
                            "Main door lock",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: const Color(0xFFF7FFFF),
                                ),
                          ),
                          Text(
                            state ? "Unlocked" : "Locked",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: const Color(0xFFF7FFFF),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 70.0),
                      padding: responde != ""
                          ? const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20)
                          : null,
                      decoration: responde != ""
                          ? BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: Text(
                        state
                            ? "Your lock is unlocked"
                            : responde != ""
                                ? responde
                                : "Your lock is locked",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: responde != ""
                                  ? Colors.red[400]
                                  : const Color(0xFFF7FFFF),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
