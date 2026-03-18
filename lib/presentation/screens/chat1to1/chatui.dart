import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/app%20url.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class Chat1to1 extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String petProfileImage;
  final int petId;
  const Chat1to1({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.petProfileImage,
    required this.petId
  });

  @override
  State<Chat1to1> createState() => _Chat1to1State();
}

class _Chat1to1State extends State<Chat1to1> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

 Future<void> _initializeChat() async {
  String? accessToken = await _getAccessToken();
  if (accessToken == null) {
    print('Access token is null, redirecting or handling token expiration.');
    handleTokenExpiration();
    return;
  }
  final token = Uri.encodeComponent(accessToken.trim());
  final petId = Uri.encodeComponent(widget.petId.toString());
  final url = 'wss://app.pawdli.com/ws/pet-chat/$petId/?token=$token';
  debugPrint('Connecting to WebSocket: $url');

  try {
    try {
      _channel.sink.close();
    } catch (_) {}

    _channel = IOWebSocketChannel.connect(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

  
    _channel.stream.listen(
      (message) => _handleIncomingMessage(message),
      onDone: () {
        debugPrint('WebSocket closed. Reconnecting...');
        _reconnectWebSocket();
      },
      onError: (error) {
        debugPrint('WebSocket error: $error. Reconnecting...');
        _reconnectWebSocket();
      },
      cancelOnError: true,
    );
  } catch (e) {
    debugPrint('Failed to connect WebSocket: $e');
    _reconnectWebSocket();
  }
}

void _handleIncomingMessage(dynamic message) {
  debugPrint('Received message: $message');

  try {
    final decoded = jsonDecode(message);

    setState(() {
      _messages.add(Message(
        text: decoded['message'] ?? '',
        sender: widget.receiverName,
        time: DateTime.tryParse(decoded['timestamp'] ?? '') ?? DateTime.now(),
        isMe: false,
        delivered: decoded['delivered'] ?? true,
        seen: decoded['seen'] ?? false,
      ));
    });
  } catch (e) {
    debugPrint('Error decoding message: $e');
  }
}

// Reconnect logic with delay
void _reconnectWebSocket() {
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) _initializeChat();
  });
}

  static void handleTokenExpiration() {
    final box = GetStorage();
    box.remove(LocalStorageConstants.access);
    box.remove(LocalStorageConstants.refresh);

    print("User must re-login. Redirecting to LoginPage...");
    Get.offAll(LoginPage()); // Replace with actual login page
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

 void _sendMessage() {
  if (_messageController.text.trim().isEmpty) return;

  final message = _messageController.text;
  final messageJson = jsonEncode({
    'to': widget.receiverId,  // the receiver's ID
    'message': message,   
    'delivered': true, // optional
  'seen': false,    // the message text
  });

  _channel.sink.add(messageJson);

  setState(() {
    _messages.add(
      Message(
        text: message,
        sender: 'You',
        time: DateTime.now(),
        isMe: true,  
      ),
    );
    _messageController.clear();
  });
}

  Future<String?> _getAccessToken() async {
    final box = GetStorage();
    var accessToken = box.read(LocalStorageConstants.access);

    if (accessToken == null) {
      print("Access token missing, attempting refresh...");
      accessToken = await refreshToken();

      if (accessToken == null) {
        handleTokenExpiration();
      }
    }

    return accessToken;
  }

  static Future<String?> refreshToken() async {
    final box = GetStorage();
    var refreshToken = box.read(LocalStorageConstants.refresh);

    if (refreshToken == null) {
      print("No refresh token found. Logging out user.");
      handleTokenExpiration();
      return null;
    }

    try {
      var response = await http.post(
        Uri.parse(AppUrl.RefershTokenURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refresh": refreshToken}),
      );

      print('Refresh token response status: ${response.statusCode}');
      print('Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('access') && jsonResponse.containsKey('refresh')) {
          String newAccessToken = jsonResponse['access'];
          String newRefreshToken = jsonResponse['refresh'];

          // Save the new tokens
          box.write(LocalStorageConstants.access, newAccessToken);
          box.write(LocalStorageConstants.refresh, newRefreshToken);

          return newAccessToken;
        }
      } else {
        // Explicitly check for token blacklist or invalid token errors
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('error') && jsonResponse['error'] == "Invalid token") {
          print("Refresh token is blacklisted or invalid. Logging out user.");
          handleTokenExpiration();
        } else {
          print("Failed to refresh token. Server response: ${response.body}");
        }
      }
    } catch (e) {
      print('Error while refreshing token: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
      String imageUrl = '${widget.petProfileImage}';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
          Center(
                                child:CircleAvatar(
  radius: 22,
  backgroundColor: Colors.grey[200],
  backgroundImage: widget.petProfileImage.isNotEmpty
      ? CachedNetworkImageProvider(widget.petProfileImage)
      : null,
  child: widget.petProfileImage.isEmpty
      ? const Icon(Icons.pets, color: Colors.brown, size: 28)
      : null,
)

                                  )
                                  ,
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(message: message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {},
          // ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class Message {
  final String text;
  final String sender;
  final DateTime time;
  final bool isMe;
  final bool delivered;
  final bool seen;
  Message({
    required this.text,
    required this.sender,
    required this.time,
    required this.isMe,
    this.delivered = false,
    this.seen = false,
  });
}
class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    String statusText = '';
    if (message.isMe) {
      if (message.seen) {
        statusText = '👀 Seen';
      } else if (message.delivered) {
        statusText = '✅ Delivered';
      } else {
        statusText = '⏳ Sent';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.sender,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isMe
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  bottomRight: message.isMe
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(message.time),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
