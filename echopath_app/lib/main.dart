import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_tts/flutter_tts.dart';

import 'package:speech_to_text/speech_to_text.dart';

void main() {

  runApp(const EchoPathApp());

}

class EchoPathApp extends StatelessWidget {

  const EchoPathApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

  debugShowCheckedModeBanner: false,

  theme: ThemeData(
    fontFamily: 'Arial',
  ),

  home: const NavigationScreen(),
);
  }
}

class NavigationScreen extends StatefulWidget {

  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() =>
      _NavigationScreenState();
}

class _NavigationScreenState
    extends State<NavigationScreen> {

  FlutterTts tts = FlutterTts();

  SpeechToText speech = SpeechToText();

  bool listening = false;

  bool routeGenerated = false;

  String statusText =
      "Press mic and say destination";

  String destination = "";

  List instructions = [];

  int currentStep = 0;

  String currentInstruction = "";



  // ---------------- INIT ---------------- //

  @override
  void initState() {

    super.initState();

    setupTTS();
  }

  Future<void> setupTTS() async {

    await tts.setLanguage("en-US");

    await tts.setSpeechRate(0.45);

    await tts.setPitch(1.0);
  }



  // ---------------- SPEAK ---------------- //

  Future<void> speak(String text) async {

    await tts.stop();

    await tts.speak(text);
  }



  // ---------------- MIC BUTTON ---------------- //

  Future<void> micButtonPressed() async {

    // FIRST TIME -> DESTINATION

    if(!routeGenerated) {

      await listenDestination();
    }

    // AFTER ROUTE GENERATED -> COMMANDS

    else {

      await listenCommand();
    }
  }



  // ---------------- DESTINATION LISTENING ---------------- //

  Future<void> listenDestination() async {

    bool available =
        await speech.initialize();

    if(available) {

      setState(() {

        listening = true;

        statusText =
            "Listening for destination...";
      });

      speech.listen(

        partialResults: false,

        onResult: (result) async {

          if(result.recognizedWords
              .isNotEmpty) {

            destination =
                result.recognizedWords;

            await speech.stop();

            setState(() {

              listening = false;

              statusText =
                  "Destination: $destination";
            });

            await fetchRoute(destination);
          }
        },
      );
    }
  }



  // ---------------- FETCH ROUTE ---------------- //

  Future<void> fetchRoute(
      String destination
  ) async {

    try {

      var url =
          "http://localhost:5000/navigate/$destination";

      var response =
          await http.get(Uri.parse(url));

      var data =
          jsonDecode(response.body);

      if(data["success"]) {

        instructions =
            data["instructions"];

        currentStep = 0;

        currentInstruction =
            instructions[0];

        setState(() {

          routeGenerated = true;

          statusText =
              "Route generated";
        });

        await speak(
            "Route generated to $destination");

        await Future.delayed(
            const Duration(seconds: 2));

        await speak(currentInstruction);
      }

      else {

        setState(() {

          statusText =
              "Destination not found";
        });

        await speak(
            "Destination not found");
      }
    }

    catch(e) {

      print(e);

      setState(() {

        statusText =
            "Backend connection failed";
      });

      await speak(
          "Backend connection failed");
    }
  }



  // ---------------- COMMAND LISTENING ---------------- //

  Future<void> listenCommand() async {

    bool available =
        await speech.initialize();

    if(available) {

      setState(() {

        listening = true;

        statusText =
            "Say next, repeat or end";
      });

      speech.listen(

        partialResults: false,

        onResult: (result) async {

          String command =
              result.recognizedWords
              .toLowerCase();

          await speech.stop();

          setState(() {

            listening = false;
          });

          handleCommand(command);
        },
      );
    }
  }



  // ---------------- HANDLE COMMAND ---------------- //

  Future<void> handleCommand(
      String command
  ) async {

    // NEXT

    if(command.contains("next")) {

      if(currentStep <
          instructions.length - 1) {

        currentStep++;

        currentInstruction =
            instructions[currentStep];

        setState(() {});

        await speak(currentInstruction);
      }

      else {

        await speak(
            "You have reached your destination");

        endNavigation();
      }
    }

    // REPEAT

    else if(command.contains("repeat")) {

      await speak(currentInstruction);
    }

    // END

    else if(command.contains("end")) {

      await speak(
          "Ending navigation");

      endNavigation();
    }

    // UNKNOWN

    else {

      await speak(
          "Command not recognized");
    }
  }



  // ---------------- END NAVIGATION ---------------- //

  void endNavigation() {

    setState(() {

      routeGenerated = false;

      currentInstruction = "";

      instructions = [];

      destination = "";

      statusText =
          "Press mic for new destination";
    });
  }



  // ---------------- UI ---------------- //

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey[200],

      body: Center(

        child: Container(

          width: 390,

          height: 844,

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(35),

            boxShadow: const [

              BoxShadow(

                blurRadius: 20,

                color: Colors.black26,

                offset: Offset(0, 8),
              )
            ],
          ),

          child: Padding(

            padding:
                const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 40),

                const Text(

                  "EchoPath",

                  style: TextStyle(

                    fontSize: 34,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),



                // STATUS

                Container(

                  padding:
                      const EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color: Colors.blue.shade50,

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Row(

                    children: [

                      Icon(

                        listening
                            ? Icons.mic
                            : Icons.navigation,

                        size: 30,
                      ),

                      const SizedBox(width: 15),

                      Expanded(

                        child: Text(

                          statusText,

                          style:
                              const TextStyle(

                            fontSize: 18,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),



                // CURRENT INSTRUCTION

                if(currentInstruction
                    .isNotEmpty)

                  Container(

                    padding:
                        const EdgeInsets.all(20),

                    decoration: BoxDecoration(

                      color:
                          Colors.green.shade50,

                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),

                    child: Text(

                      currentInstruction,

                      style: const TextStyle(

                        fontSize: 24,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 25),



                // MAP IMAGE

                Container(

                  height: 250,

                  width: double.infinity,

                  decoration: BoxDecoration(

                    borderRadius:
                        BorderRadius.circular(
                            20),

                    image:
                        const DecorationImage(

                      image: AssetImage(
                          'assets/hospital_map.png'),

                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const Spacer(),



                // MIC BUTTON

                Center(

                  child: FloatingActionButton(

                    onPressed:
                        micButtonPressed,

                    backgroundColor:
                        Colors.black,

                    child: const Icon(

                      Icons.mic,

                      size: 35,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}