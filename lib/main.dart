import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JokeTellingScreen(),
    );
  }
}

class JokeTellingScreen extends StatefulWidget {
  @override
  _JokeTellingScreenState createState() => _JokeTellingScreenState();
}

class _JokeTellingScreenState extends State<JokeTellingScreen> {
  FlutterTts flutterTts = FlutterTts();
  String setup = "Press the button for a joke!";
  String delivery = "";
  String selectedVoice = "en-US";

  Future<void> speak(String text) async {
    await flutterTts.setLanguage(selectedVoice);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> fetchJoke() async {
    final response = await http.get(Uri.parse('https://v2.jokeapi.dev/joke/Any'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        if (data['type'] == 'twopart') {
          setup = data['setup'];
          delivery = data['delivery'];
        } else {
          setup = data['joke'];
          delivery = "";
        }
      });
    } else {
      throw Exception('Failed to load joke');
    }
  }

  Future<void> generateJoke() async {
    try {
      await fetchJoke();
      await Future.delayed(Duration(seconds: 1)); // Optional delay for better user experience

      // Read the entire content displayed on the screen
      await speak("$setup $delivery");

    } catch (e) {
      print('Error fetching or speaking joke: $e');
    }
  }

  void showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            children: [
              ListTile(
                title: Text('English (US)'),
                onTap: () {
                  setLanguage('en-US');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Spanish (Spain)'),
                onTap: () {
                  setLanguage('es-ES');
                  Navigator.pop(context);
                },
              ),
              // Add more language options as needed
            ],
          ),
        );
      },
    );
  }

  Future<void> setLanguage(String languageCode) async {
    setState(() {
      selectedVoice = languageCode;
    });

    await flutterTts.setLanguage(languageCode);
  }

  void setVoice(String voiceName) {
    flutterTts.setVoice(voiceName as Map<String, String>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joker'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showSettingsBottomSheet();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                setup,
                style: TextStyle(fontSize: 18.0, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (delivery.isNotEmpty)
                Text(
                  delivery,
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  generateJoke();
                },
                child: Text('Tell me a Joke'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
