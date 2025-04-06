import 'package:codeshastra_app/utility/sizedbox_util.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(
          'https://reception-poultry-ec-booking.trycloudflare.com/code_assistant',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': userMessage, 'language': 'en'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add(ChatMessage(text: data['response'], isUser: false));
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Sorry, something went wrong. Please try again.',
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Network error. Please check your connection.',
            isUser: false,
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'Chat Assistant',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(maxHeight: 100),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          vSize(10),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  Widget _buildAvatar(String letter, Color textColor) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFD0E8B5),
      child: Text(
        letter,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            _buildAvatar('L', Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 0),
                  bottomRight: Radius.circular(message.isUser ? 0 : 20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color:
                      message.isUser
                          ? Colors.black
                          : Theme.of(context).primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar('N', Colors.black),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<ChatMessage> _messages = [];
//   bool _isLoading = false;

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final userMessage = _messageController.text;
//     _messageController.clear();

//     setState(() {
//       _messages.add(ChatMessage(text: userMessage, isUser: true));
//       _isLoading = true;
//     });

//     _scrollToBottom();

//     try {
//       final response = await http.post(
//         Uri.parse(
//           'https://reception-poultry-ec-booking.trycloudflare.com/code_assistant',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'query': userMessage, 'language': 'en'}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _messages.add(ChatMessage(text: data['response'], isUser: false));
//         });
//       } else {
//         setState(() {
//           _messages.add(
//             ChatMessage(
//               text: 'Sorry, something went wrong. Please try again.',
//               isUser: false,
//             ),
//           );
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add(
//           ChatMessage(
//             text: 'Network error. Please check your connection.',
//             isUser: false,
//           ),
//         );
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//       _scrollToBottom();
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).primaryColorDark,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Theme.of(context).primaryColorDark,
//         title: Text(
//           'Chat Assistant',
//           style: TextStyle(color: Theme.of(context).primaryColor),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 return MessageBubble(message: message);
//               },
//             ),
//           ),
//           if (_isLoading)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   Theme.of(context).primaryColor,
//                 ),
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               border: Border(
//                 top: BorderSide(
//                   color: Theme.of(context).primaryColor.withOpacity(0.2),
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     style: TextStyle(color: Theme.of(context).primaryColor),
//                     decoration: InputDecoration(
//                       hintText: 'Type your message...',
//                       hintStyle: TextStyle(
//                         color: Theme.of(context).primaryColor.withOpacity(0.6),
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Theme.of(
//                         context,
//                       ).primaryColor.withOpacity(0.1),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                     ),
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isUser;

//   ChatMessage({required this.text, required this.isUser});
// }

// class MessageBubble extends StatelessWidget {
//   final ChatMessage message;

//   const MessageBubble({super.key, required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color:
//               message.isUser
//                   ? Theme.of(context).primaryColor
//                   : Theme.of(context).primaryColor.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           message.text,
//           style: TextStyle(
//             color:
//                 message.isUser ? Colors.black : Theme.of(context).primaryColor,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }
