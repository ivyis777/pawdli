import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/mysubscriptioncontroller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';



class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
class ChatMessage {
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final String senderId;
   final String? senderName;

  ChatMessage({
    required this.message,
    required this.timestamp,
    required this.isMe,
    required this.senderId,
    this.senderName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          senderId == other.senderId &&
          timestamp == other.timestamp &&
          senderName == other.senderName;

  @override
  int get hashCode =>
      message.hashCode ^ senderId.hashCode ^ timestamp.hashCode;
}




class VideoCallPage extends StatefulWidget {
  final int? userId;
  final String appId;
  final String? channelName;
  final String? token;
  final String? programType;
  final int? uid;
  final int? sessionId;
  final bool isCaller;
  final int? hostUid;
 final bool?isRestart;

  const VideoCallPage({
    Key? key,
     required this.userId,
    required this.appId,
    required this.channelName,
    required this.token,
    required this.programType,
    required this.uid,
    required this.sessionId,
    this.isCaller = true,
    this.hostUid,
     this.isRestart,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> with WidgetsBindingObserver {
  late RtcEngine _engine;
  final List<int> remoteUids = [];
  bool isJoined = false;
  bool muted = false;
  bool cameraOff = false;
  List<String> messages = [];
  String currentUserName = '';
  WebSocketChannel? _callChannel;
  bool isLoadingChatToken = false;
  bool isChatVisible = false;
  TextEditingController chatController = TextEditingController();
  StreamSubscription? _callSubscription;
  bool isCallWsConnected = false;
  bool _isEngineReleased = false;
     bool _isCameraBusy = false;
  // Chat related variables
  final List<ChatMessage> _messages = [];
  final _messageSet = HashSet<ChatMessage>();
  bool _isFrontCamera = true;
  List<String> _debugLogs = [];
  int _reconnectAttempts = 0;
  DateTime? _lastConnectionChange;
  int _wsRetryCount = 0;
static const int _maxWsRetries = 5;


  @override

void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _startVideoCallSafely(); 
  });

  // _initializeWebSocketChannel();

  SharedPreferences.getInstance().then((prefs) {
    setState(() {
      currentUserName = prefs.getString(LocalStorageConstants.name) ?? 'You';
    });
  });
}


 
 @override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
    final subscriptionController = Get.find<SubscriptionController>();
  subscriptionController.hasActiveSession.value = false;
  subscriptionController.currentSessionId.value = 0;
  _cleanupAgoraEngine();
  _callChannel?.sink.close();
  _callSubscription?.cancel();
  chatController.dispose();
  super.dispose();
}
Future<void> _disposeOtherCameraPlugins() async {
  try {
    // If you’re using `camera` plugin elsewhere, dispose it here.
    // Example:
    // await _cameraController?.dispose();
    // _cameraController = null;
    debugPrint("Disposed other camera plugins before Agora init");
  } catch (e) {
    debugPrint("No other camera plugin to dispose: $e");
  }
}

Future<void> _startVideoCallSafely() async {
  final hasPermission = await _checkPermissions();
if (hasPermission) {
  await _disposeOtherCameraPlugins();
  await initAgora();

  } else {
    debugPrint('Camera or microphone permission not granted');
  }
}


  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

void _initializeWebSocketChannel() async {
  if (widget.channelName == null || widget.channelName!.trim().isEmpty || widget.userId == null) {
    debugPrint('❌ Missing or invalid parameters for WebSocket');
    _showErrorSnackbar('Cannot start chat: missing channel or user info.');
    return;
  }

  try {
    final tokenRaw = await ApiService.getAccessToken();
    if (tokenRaw == null || tokenRaw.trim().isEmpty) {
      _showErrorSnackbar('Authentication required');
      return;
    }
debugPrint('Token: $tokenRaw');
debugPrint('Channel: ${widget.channelName}');
final token = Uri.encodeComponent(tokenRaw.trim());
final channelName = Uri.encodeComponent(widget.channelName!.trim());

    final wsUrl = 'wss://app.pawdli.com/ws/call/$channelName/?token=$token';

    debugPrint('🌐 Connecting to WebSocket: $wsUrl');

    // Close existing connection safely
    await _callChannel?.sink.close();
    await _callSubscription?.cancel();

    _callChannel = WebSocketChannel.connect(
  Uri.parse(wsUrl),
  protocols: const ['websocket'],
);


    if (mounted) {
  setState(() {
    isCallWsConnected = true;
    _wsRetryCount = 0; // ✅ reset
  });
}


    _callSubscription = _callChannel!.stream.listen(
      (message) => _handleIncomingMessage(message),
      onError: (error) {
        debugPrint('❌ WS ERROR TYPE: ${error.runtimeType}');
        debugPrint('❌ WebSocket error: $error');
        if (mounted) setState(() => isCallWsConnected = false);
        _reconnectWebSocket();
      },
      onDone: () {
        debugPrint('🔒 WebSocket connection closed');
        if (mounted) setState(() => isCallWsConnected = false);
        if (mounted) _reconnectWebSocket();
      },
    );

    // Timeout safeguard
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !isCallWsConnected) {
        debugPrint('⏱ WebSocket connection timeout');
        _showErrorSnackbar('Connection timeout. Retrying...');
        _reconnectWebSocket();
      }
    });
  } catch (e) {
    debugPrint('❌ WebSocket init error: $e');
    if (mounted) {
      setState(() => isCallWsConnected = false);
      _showErrorSnackbar('Connection error: ${e.toString()}');
    }
    _reconnectWebSocket();
  }
}

void _reconnectWebSocket() {
  if (!mounted) return;
  if (!isJoined) return;


  if (_wsRetryCount >= _maxWsRetries) {
    debugPrint('❌ WebSocket retry limit reached');
    _showErrorSnackbar('Chat connection failed');
    return;
  }

  _wsRetryCount++;
  final delay = Duration(seconds: 2 * _wsRetryCount);

  debugPrint('🔁 Reconnecting WebSocket (attempt $_wsRetryCount)...');

  Future.delayed(delay, () {
    if (mounted) _initializeWebSocketChannel();
  });
}



void _handleIncomingMessage(dynamic message) {
  try {
    debugPrint('Processing message: $message');
    
    dynamic parsedMessage;
    if (message is String) {
      parsedMessage = jsonDecode(message);
    } else if (message is Map) {
      parsedMessage = message;
    } else {
      debugPrint('Unknown message format');
      return;
    }

    // Handle call_ended message with force_disconnect action
    if (parsedMessage['type'] == 'call_ended' && parsedMessage['action'] == 'force_disconnect') {
      debugPrint('Call ended, force disconnect received');
      _endCallForListener(); // End the call and navigate away
    }
    // Handle other messages such as chat_message or call_message
    else if (parsedMessage['type'] == 'chat_message') {
      _processChatMessage(parsedMessage);
    } else if (parsedMessage['type'] == 'call_message' && parsedMessage['message'] != null) {
      final inner = parsedMessage['message'];
      if (inner is String) {
        final decoded = jsonDecode(inner);
        if (decoded['type'] == 'chat_message') {
          _processChatMessage(decoded);
        }
      } else if (inner is Map && inner['type'] == 'chat_message') {
        _processChatMessage(inner);
      }
    }
  } catch (e) {
    debugPrint('Error processing message: $e');
  }
}
void _endCallForListener() async {
  await _cleanupAgoraEngine();

  if (!mounted) return;

Navigator.of(context, rootNavigator: true).pop();

}



// Update your sendMessage method:
void sendMessage() async {
  final messageText = chatController.text.trim();
  if (messageText.isEmpty || widget.userId == null) return;

  final messageData = {
    'type': 'chat_message',
    'message': messageText,
    'sender_id': widget.userId,
    'session_id': widget.sessionId,
    'timestamp': DateTime.now().toIso8601String(),
  };

  final optimisticMessage = ChatMessage(
    message: messageText,
    timestamp: DateTime.now(),
    isMe: true,
    senderId: widget.userId.toString(),
  );

  if (mounted) {
    setState(() {
      _messages.insert(0, optimisticMessage);
      _messageSet.add(optimisticMessage);
    });
  }

  try {
    // Send as a direct chat message (not nested)
    _callChannel?.sink.add(jsonEncode(messageData));
    chatController.clear();
  } catch (e) {
    debugPrint('Send message error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }
}

void _processChatMessage(dynamic messageData) {
  try {
    debugPrint('Processing chat message: $messageData');
    
    // Ensure we have the basic required fields
    if (messageData['message'] == null || messageData['sender_id'] == null) {
      debugPrint('Invalid chat message format');
      return;
    }

    final senderId = messageData['sender_id'].toString();
    final currentUserId = widget.userId.toString();
    final isMe = senderId == currentUserId;

    final newMessage = ChatMessage(
      message: messageData['message'].toString(),
      timestamp: DateTime.tryParse(messageData['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isMe: isMe,
      senderId: senderId,
      senderName: messageData['sender_name']?.toString(), // Add this line
    );

    if (!_messageSet.contains(newMessage) && mounted) {
      setState(() {
        _messages.insert(0, newMessage);
        _messageSet.add(newMessage);
      });
    }
  } catch (e) {
    debugPrint('Error processing chat message: $e');
  }
}
Future<bool> _checkPermissions() async {
  final camStatus = await Permission.camera.status;
  final micStatus = await Permission.microphone.status;

  print('📷 Camera: $camStatus | 🎤 Microphone: $micStatus');

  if (camStatus.isGranted && micStatus.isGranted) return true;

  final result = await [Permission.camera, Permission.microphone].request();

  print('🟢 Permission request result: $result');

  final cam = await Permission.camera.status;
  final mic = await Permission.microphone.status;

  if (cam.isPermanentlyDenied || mic.isPermanentlyDenied) {
    _showPermissionDialog(); // 👉 Show dialog to open Settings
    return false;
  }

  if (!cam.isGranted || !mic.isGranted) {
    _showErrorSnackbar('Camera or microphone permission denied');
    return false;
  }

  return true;
}

void _showPermissionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Permissions Required'),
      content: const Text(
          'Camera and microphone access are permanently denied. Please enable them in Settings > Privacy > Camera & Microphone.'),
      actions: [
        TextButton(
          child: const Text('Open Settings'),
          onPressed: () {
            openAppSettings(); // 🚀 from permission_handler
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}


  Future<void> initAgora() async {
  // ✅ Request permissions just once
   if (await Permission.camera.isPermanentlyDenied || await Permission.microphone.isPermanentlyDenied) {
    openAppSettings(); // This opens iOS settings page
    _showErrorSnackbar('Please allow camera and microphone access in Settings > Privacy.');
    return;
  }
  final status = await [Permission.camera, Permission.microphone].request();

  final cam = await Permission.camera.status;
  final mic = await Permission.microphone.status;

  if (!cam.isGranted || !mic.isGranted) {
    _showErrorSnackbar('Camera or microphone permission denied');
    return;
  }

  // ✅ Initialize Agora engine
  _engine = createAgoraRtcEngine();
  await _engine.initialize(RtcEngineContext(appId: widget.appId));
  await _engine.setParameters('''
{
  "rtc.enable_turn": true,
  "rtc.turn_server": [
    {
      "server": "turn:13.200.89.0:3478",
      "username": "testuser",
      "password": "MyStrongSecretKey123",
      "udp_port": 3478,
      "tcp_port": 3478
    }
  ]
}
''');

  // ✅ Register event handlers (hybrid: simple + debug essentials)
_engine.registerEventHandler(
  RtcEngineEventHandler(
    // 👀 Debug: connection lifecycle
    onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
      print("[CONNECTION STATE] $state, Reason: $reason");
      if (state == ConnectionStateType.connectionStateFailed) {
        print("❌ Connection failed! Reason: $reason");
      }
    },

    // 👀 Debug: Agora errors
    onError: (ErrorCodeType err, String msg) {
      print("[AGORA ERROR] $err: $msg");
    },

    // ✅ Local join
    onJoinChannelSuccess: (connection, elapsed) {
      print("✅ Local user joined: ${connection.localUid}");
      setState(() => isJoined = true);
       _initializeWebSocketChannel();
    },

    // ✅ Remote join
    onUserJoined: (connection, remoteUid, elapsed) {
      print("👤 Remote user joined: $remoteUid");
      setState(() => remoteUids.add(remoteUid));
    },

    // ✅ Remote leave
    onUserOffline: (connection, remoteUid, reason) {
      print("🚪 Remote user left: $remoteUid");
      setState(() => remoteUids.remove(remoteUid));

      if (!widget.isCaller && remoteUid == widget.hostUid) {
        print("👋 Host left — ending call for listener...");
        _engine.leaveChannel();
        Navigator.pop(context);
      }
    },

    // ✅ Token renewal
    onTokenPrivilegeWillExpire: (connection, token) async {
      print("🔑 Token expiring soon, renewing...");
      final refreshToken = await ApiService.refreshToken();
     await _engine.renewToken(refreshToken.toString());

    },
  ),
);


  // ✅ Set log level (optional but helpful)
  await _engine.setLogLevel(LogLevel.logLevelInfo);

  // ✅ Enable and configure video
  await _engine.enableVideo();
  await _engine.setVideoEncoderConfiguration(const VideoEncoderConfiguration(
    dimensions: VideoDimensions(width: 640, height: 480),
    frameRate: 15,
    bitrate: 0,
  ));

  // ✅ Setup local video view
  await _engine.setupLocalVideo(const VideoCanvas(uid: 0));
  await _engine.startPreview();
debugPrint("🎫 Agora Token: ${widget.token}");
debugPrint("📡 Channel Name: ${widget.channelName}");
debugPrint("👤 UID: ${widget.uid}");
  // ✅ Join channel
  await _engine.joinChannel(
    token: widget.token!,
    channelId: widget.channelName!,
    uid: widget.uid!,
    options: const ChannelMediaOptions(
      channelProfile: ChannelProfileType.channelProfileCommunication,
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      
    ),
  );
 
}


Future<void> _cleanupAgoraEngine() async {
  if (_isEngineReleased) return;
  _isEngineReleased = true;

  try {
    await _engine.leaveChannel();
  } catch (e) {
    debugPrint('Error leaving channel: $e');
  }

  try {
    await _engine.release();
    debugPrint("Agora engine released successfully");
  } catch (e) {
    debugPrint('Error releasing Agora engine: $e');
  }
}

Future<void> _switchCamera() async {
  try {
    // Only switch if video is enabled
    if (!cameraOff) {
      await _engine.switchCamera();
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera is off, turn it on first')),
        );
      }
    }
  } catch (e) {
    debugPrint('Error switching camera: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to switch camera')),
      );
    }
  }
}

Future<void> _toggleCamera() async {
  if (_isCameraBusy || !mounted) return;

  setState(() => _isCameraBusy = true);

  try {
    if (cameraOff) {
      // Turn ON camera
      await _engine.enableVideo();
      await _engine.muteLocalVideoStream(false);
    } else {
      // Turn OFF camera (mute stream instead of stopping preview)
      await _engine.muteLocalVideoStream(true);
    }

    if (mounted) {
      setState(() => cameraOff = !cameraOff);
      _sendCameraStateToParticipants();
    }
  } catch (e) {
    debugPrint('Camera toggle error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera toggle failed: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) setState(() => _isCameraBusy = false);
  }
}

Future<void> _sendCameraStateToParticipants() async {
    if (_callChannel == null || !mounted) return;
    
    try {
      _callChannel!.sink.add(jsonEncode({
        'type': 'camera_state',
        'userId': widget.userId,
        'isCameraOn': !cameraOff,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      debugPrint('Error sending camera state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isJoined
          ? Stack(
              children: [
                Positioned.fill(
                  child: widget.programType == "Video"
                      ? _renderAllVideos()
                      : const Center(child: Text("Audio Call")),
                ),
                _toolbar(),
                _participantList(),
                
                if (isChatVisible) _buildChatUI(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _renderAllVideos() {
    final views = <Widget>[
      if (!cameraOff)
       AgoraVideoView(
  controller: VideoViewController(
    rtcEngine: _engine,
    canvas: const VideoCanvas(uid: 0),
  ),
)

      else
        Container(
          color: Colors.grey[900],
          child: const Center(
              child: Icon(Icons.videocam_off, size: 40, color: Colors.white)),
        ),
      ...remoteUids.map(
        (uid) => AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: uid),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        ),
      ),
    ];

    int crossAxisCount = views.length <= 2 ? 1 : (views.length <= 4 ? 2 : 3);


    return GridView.builder(
      itemCount: views.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
      ),
      itemBuilder: (_, index) => Container(
        margin: const EdgeInsets.all(4),
        color: Colors.black,
        child: views[index],
      ),
    );
  }

  Widget _toolbar() {
  return Align(
    alignment: Alignment.bottomCenter,
    
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _iconButton(
            icon: muted ? Icons.mic_off : Icons.mic,
            color: muted ? Colors.red : Colors.white,
            onPressed: () {
              setState(() => muted = !muted);
              _engine.muteLocalAudioStream(muted);
            },
          ),
          _iconButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: () async {
              try {
                if (mounted) setState(() => remoteUids.clear());

                if (widget.sessionId != null) {
                  if (widget.isCaller) {
                    await ApiService.endCall(
                      userId: widget.userId!,
                      sessionId: widget.sessionId!,
                    );
                  } else {
                    await ApiService.LeaveCall(
                      userId: widget.userId!,
                      sessionId: widget.sessionId!,
                    );
                  }
                }

                await _cleanupAgoraEngine();
                _callChannel?.sink.close();

                if (mounted) Navigator.pop(context);
              } catch (e) {
                debugPrint('Error ending call: $e');
                if (mounted) {
                  _showErrorSnackbar('Error ending call: ${e.toString()}');
                }
              }
            },
          ),
          if (widget.programType != "Audio")
            _iconButton(
              icon: cameraOff ? Icons.videocam_off : Icons.videocam,
              color: cameraOff ? Colors.red : Colors.white,
              onPressed: _isCameraBusy ? null : () => _toggleCamera(),
            ),
          if (widget.programType != "Audio")
            _iconButton(
              icon: Icons.cameraswitch,
              color: Colors.white,
              onPressed: (_isCameraBusy || cameraOff) ? null : () => _switchCamera(),
            ),
          _iconButton(
            icon: isChatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline,
            color: Colors.white,
            onPressed: () {
              setState(() => isChatVisible = !isChatVisible);
            },
          ),
        ],
      ),
    ),
  );
}

    Widget _buildChatUI() {
    return Positioned(
      right: 16,
      bottom: 80,
      child: Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isCallWsConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Chat ${isCallWsConnected ? 'Connected' : 'Disconnected'}',
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
    IconButton(
      icon: const Icon(Icons.close, size: 18, color: Colors.white),
      onPressed: () => setState(() => isChatVisible = false),
    ),
  ],
),

            ),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: chatController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildMessageBubble(ChatMessage message) {

  final displayName = message.isMe 
      ? currentUserName 
      : message.senderName ?? 'Participant';

  // Get avatar color based on senderId
  final avatarColor = _getAvatarColor(message);
  // Get avatar text (first letter of name)
  final avatarText = displayName.substring(0, 1).toUpperCase();

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!message.isMe)
          CircleAvatar(
            radius: 12,
            backgroundColor: avatarColor,
            child: Text(
              avatarText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: message.isMe ? Colors.blue : Colors.grey[800],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(message.isMe ? 12 : 0),
                bottomRight: Radius.circular(message.isMe ? 0 : 12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name with online indicator
                Row(
                  children: [
                    if (!message.isMe)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: message.isMe ? Colors.white : avatarColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.message,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (message.isMe)
          CircleAvatar(
            radius: 12,
            backgroundColor: avatarColor,
            child: Text(
              avatarText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    ),
  );
}


Color _getAvatarColor(ChatMessage message) {
  if (message.isMe) return Colors.blue;
  final colors = [Colors.amber, Colors.green, Colors.purple, Colors.purple];
  return colors[message.senderId.hashCode % colors.length];
}

Widget _iconButton({
  required IconData icon,
  required Color color,
  required VoidCallback? onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade800, // Grey background for icon
      shape: BoxShape.circle,
    ),
    padding: const EdgeInsets.all(2), // Adjust padding as needed
    child: IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    ),
  );
}

  Widget _participantList() {
    return Positioned(
      top: 40,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Participants: ${remoteUids.length + 1}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
  void _logDebug(String message, {bool isError = false}) {
  final timestamp = DateTime.now().toIso8601String().substring(11, 19);
  final logEntry = '[$timestamp] ${isError ? '🔴 ' : '🟢 '}$message';
  
  debugPrint(logEntry);
  if (mounted) {
    setState(() => _debugLogs.insert(0, logEntry));
  }
}

}
