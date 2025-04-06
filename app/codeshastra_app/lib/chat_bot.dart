// import 'dart:convert';
// import 'package:ai_farmer_app/Constants/app_colors.dart';
// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:http/http.dart' as http;
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;

// class Chat_Widget extends StatefulWidget {
//   const Chat_Widget({super.key});

//   @override
//   State<Chat_Widget> createState() => _Chat_WidgetState();
// }

// class _Chat_WidgetState extends State<Chat_Widget> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   TextEditingController controller = TextEditingController();
//   bool isRecording = false;
//   List<ChatUser> typing = [];
//   ChatUser myself = ChatUser(id: "1", firstName: "Neel");
//   ChatUser bot = ChatUser(id: "2", firstName: "Bot");

//   // final url =
//   //     "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyA-JNuW2DQaMDYI4khARZ967ML-QbOPoEc";

//   final header = {
//     'Content-Type': 'application/json',
//   };

//   List<ChatMessage> allMessages = [];

//   @override
//   void initState() {
//     super.initState();
//     //initializeSpeech();
//     _initializeChat();
//   }

//   void initializeSpeech() async {
//     bool available = await _speech.initialize();
//     if (!available) {
//       if (kDebugMode) {
//         print('The user denied access to the microphone');
//       }
//     }
//   }

//   void startRecording() async {
//     if (_speech.isListening) {
//       setState(() {
//         controller.text = ''; // Reset text field if already recording
//       });
//       return;
//     }

//     setState(() {
//       isRecording = true;
//     });

//     bool available = await _speech.initialize();
//     if (available) {
//       _speech.listen(
//         onResult: (result) {
//           setState(() {
//             controller.text = result.recognizedWords;
//           });
//         },
//         onSoundLevelChange: (level) {},
//         listenOptions: SpeechListenOptions(cancelOnError: true),
//       );
//     }
//   }

//   void stopRecording() {
//     if (_speech.isListening) {
//       _speech.stop();
//     }
//     setState(() {
//       isRecording = false;
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     controller.dispose();
//     _speech.cancel();
//   }

//   void _initializeChat() {
//     // Initial message 2
//     ChatMessage initialMessage2 = ChatMessage(
//       text: "Hi I'm, Farmer's Interactive Assistant. ",
//       user: bot,
//       createdAt: DateTime.now(),
//     );

//     // Initial message 1
//     ChatMessage initialMessage1 = ChatMessage(
//       text: "What can I help you with today?",
//       user: bot,
//       createdAt: DateTime.now(),
//     );

//     // Add initial messages to the chat
//     allMessages.insert(0, initialMessage2);
//     allMessages.insert(0, initialMessage1);
//   }

//   void getData(ChatMessage m) async {
//     // Add the bot to the typing users list and display the user's message
//     typing.add(bot);
//     allMessages.insert(0, m);
//     setState(() {});

//     // Create the request data in the format expected by the new API
//     var data = {
//       "query": m.text, // The user's input
//     };
//     print("///////${m.text}");

//     // Make a POST request to the new API
//     await http
//         .post(
//       Uri.parse("https://nfc2-w3ri.onrender.com/api/chat"), // New API endpoint
//       headers: header,
//       body: jsonEncode(data),
//     )
//         .then((response) {
//       if (response.statusCode == 200) {
//         var result = jsonDecode(response.body);
//         if (kDebugMode) {
//           print(result); // Print the API response to debug
//         }

//         // Extract the response text from the API's result
//         String responseText = result["result"] ??
//             "Sorry, I didn't get that."; // Adjusted to match the response key

//         // Create a new ChatMessage with the API's response
//         ChatMessage botMessage = ChatMessage(
//           text: responseText,
//           user: bot,
//           createdAt: DateTime.now(),
//         );
//         allMessages.insert(0, botMessage); // Add the bot's response to the chat
//       } else {
//         if (kDebugMode) {
//           print("Error Occurred: ${response.body}"); // Print any errors
//         }
//       }
//     }).catchError((e) {
//       if (kDebugMode) {
//         print("Error Occurred: $e");
//       }
//     });

//     // Remove the bot from the typing users list
//     typing.remove(bot);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     double w = MediaQuery.of(context).size.width;
//     double h = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         automaticallyImplyLeading: true,
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: CircleAvatar(
//                 radius: 10,
//                 backgroundColor: Colors.transparent,
//                 child: Icon(
//                   Icons.arrow_back,
//                   color: AppColors.greenn,
//                 )),
//           ),
//         ),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: DashChat(
//               typingUsers: typing,
//               currentUser: myself,
//               onSend: (ChatMessage m) {
//                 getData(m);
//               },
//               messageOptions: const MessageOptions(
//                 currentUserContainerColor: AppColors.greenn,
//                 containerColor: Color(0xFFEEEEEE),
//                 showOtherUsersAvatar: false,
//                 textColor: AppColors.black,
//               ),
//               messages: allMessages,
//               inputOptions: InputOptions(
//                   alwaysShowSend: true,
//                   textController: controller,
//                   sendOnEnter: true,
//                   inputTextStyle: const TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                   ),
//                   // cursorStyle: const CursorStyle(color: Colors.red),
//                   inputToolbarStyle: BoxDecoration(
//                     borderRadius: const BorderRadius.all(Radius.circular(15)),
//                     border: const Border(
//                       top: BorderSide(color: Colors.white),
//                       left: BorderSide(color: Colors.white),
//                       right: BorderSide(color: Colors.white),
//                       bottom: BorderSide(color: Colors.white),
//                     ),
//                     backgroundBlendMode: BlendMode.color,
//                     color: Colors.white.withOpacity(0.0),
//                   ),
//                   inputToolbarMargin: const EdgeInsets.all(13),
//                   inputDecoration: InputDecoration(
//                     prefixIcon: IconButton(
//                       icon: Icon(
//                         isRecording ? Icons.mic_none : Icons.mic,
//                         color: AppColors.greenn,
//                       ),
//                       onPressed: isRecording ? stopRecording : startRecording,
//                     ),
//                     hintText: "Enter Your Query",
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     border: InputBorder.none,
//                   )),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
