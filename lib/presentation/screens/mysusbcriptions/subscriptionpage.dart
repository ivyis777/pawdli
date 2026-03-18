import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/api%20service.dart';
import 'package:pawlli/data/controller/mysubscriptioncontroller.dart';
import 'package:pawlli/data/model/mysubscriptionmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/agora/videocallpage.dart';


class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {

  SubscriptionController get controller {
    try {
      return Get.find<SubscriptionController>();
    } catch (e) {
      return Get.put(SubscriptionController());
    }
  }

  bool _isLoading = false;
  int? _sessionId;
  String _selectedRoleFilter = 'All';
  Map<int, bool> _hostHasJoined = {};
  Map<int, DateTime> _programStartTimes = {};
   bool _isRestart = false;
  @override
  void initState() {
    super.initState();
  if (!Get.isRegistered<SubscriptionController>()) {
      Get.put(SubscriptionController());
    }
    
    _loadSubscriptions();
    _startPollingHostStatus();
  }
void _startPollingHostStatus() {
  Timer.periodic(Duration(seconds: 10), (timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }
    _checkAllHostStatuses();
  });
}

 Future<void> _loadSubscriptions() async {
  final box = GetStorage();
  final userId = box.read(LocalStorageConstants.userId);

  if (userId != null) {
    await controller.fetchAllSubscriptions(userId);
    // Ensure subscriptions are loaded before initializing other data
    if (controller.programDataList.isNotEmpty) {
      for (var program in controller.programDataList) {
        _hostHasJoined[program.bookingId!] = false;
        _programStartTimes[program.bookingId!] = _parseStartTime(program.date, program.time);
      }
    }
  } else {
    controller.isLoading.value = false;
  }
}
void _updateHostStatus(int bookingId, bool hasJoined) {
  _hostHasJoined[bookingId] = hasJoined;
}


Future<void> _checkAllHostStatuses() async {
  for (var program in controller.programDataList) {
    if (program.bookingId == null || program.isHost) continue;

    final bookingId = program.bookingId!;
    
    if (!_programStartTimes.containsKey(bookingId)) {
      _programStartTimes[bookingId] = _parseStartTime(program.date, program.time);
    }

    if (isProgramStarted(program.date, program.time, bookingId)) {
      final currentStatus = _hostHasJoined[bookingId] ?? false;
      if (!currentStatus) {
        _updateHostStatus(bookingId, true);
      }
    }
  }
}
DateTime _parseStartTime(String date, String timeRange) {
  try {
    final startTimeStr = timeRange.split('-').first.trim();
    final combined = "$date $startTimeStr";
    print("📅 Trying to parse start time: $combined");

    final format = DateFormat("yyyy-MM-dd hh:mm a"); 
    final parsed = format.parseStrict(combined).toLocal(); 
    print("✅ Parsed local start time: $parsed");

    return parsed;
  } catch (e) {
    print("❌ Failed to parse start time: $e");
    return DateTime.now().add(Duration(days: 365)); 
  }
}
  bool isProgramExpired(String date, String timeRange) {
    try {
      final endTimeStr = timeRange.split('-').last.trim();
      final combined = "$date $endTimeStr";
      final format = DateFormat("yyyy-MM-dd hh:mm a");
      final endDateTime = format.parse(combined);
      return DateTime.now().isAfter(endDateTime);
    } catch (e) {
      return true;
    }
  }
bool isProgramStarted(String date, String timeRange, int bookingId) {
  final startTime = _programStartTimes[bookingId];
  final endTime = _parseEndTime(date, timeRange);  // Pass the 'date' to _parseEndTime
  final now = DateTime.now();
  
  print("⏰ Checking program start for bookingId: $bookingId");
  print("Now: $now, Start Time: $startTime, End Time: $endTime");

  if (startTime == null) {
    print("🚨 No start time found for bookingId: $bookingId");
    return false; // Can't compare if we don't have a valid start time
  }

  // Log the comparison
  final result = now.isAfter(startTime) && now.isBefore(endTime);
  print("🧮 now.isAfter(startTime) && now.isBefore(endTime) = $result");
  return result;
}

DateTime _parseEndTime(String date, String timeRange) {
  try {
    final endTimeStr = timeRange.split('-').last.trim();  // Extract the end time from the range
    final combined = "$date $endTimeStr";  // Combine the date with the end time
    final format = DateFormat("yyyy-MM-dd hh:mm a");  // Use appropriate format for time
    final parsed = format.parseStrict(combined).toLocal();  // Parse to DateTime in local timezone
    print("✅ Parsed local end time: $parsed");
    return parsed;
  } catch (e) {
    print("❌ Failed to parse end time: $e");
    return DateTime.now().add(Duration(days: 365));  // Return a far future date on error
  }
}


void _handleProgramAction(ProgramData program) async {
  final userId = GetStorage().read(LocalStorageConstants.userId);
  if (userId == null) return;

  if (program.isHost) {
    // If the user is the host, start the session
    handleProgramStart(userId, program.bookingId!, program.time, program.date, program.programType!);
  } else {
    // If the user is a listener, check the program status
    if (!isProgramStarted(program.date, program.time, program.bookingId!)) {
  // Session has not started yet
  final startTime = program.time.split('-').first.trim();
showStartTimePopup(startTime, program.date);

} else if (!(_hostHasJoined[program.bookingId] ?? false)) {
  // Session started, but host hasn't joined
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Host has not started the session yet. Please wait.')));
} else {
  // Host joined and session started, user can join
  print('Host has joined, proceeding to join the session.');
  handleJoinCall(userId, program.bookingId);
}

  }
}


   @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final screenSize = MediaQuery.of(context).size;
    final controller = Get.put(SubscriptionController());
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: screenWidth * 0.55,
              height: screenHeight * 0.10,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.topimage.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(screenHeight * 0.12),
                child: AppBar(
                  title: Text(
                    'Subscription',
                    style: TextStyle(
                      fontSize: screenHeight * 0.03,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.Cairo,
                      color: Colours.black,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
          
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text("Filter: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _selectedRoleFilter,
                      items: ['All', 'Host', 'Listener'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRoleFilter = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
          
              
           Expanded(
  child: Obx(() {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }
    
    // Separate active and expired programs
    final activePrograms = <ProgramData>[];
    final expiredPrograms = <ProgramData>[];
    
    for (var program in controller.programDataList) {
      if (isProgramExpired(program.date, program.time)) {
        expiredPrograms.add(program);
      } else {
        activePrograms.add(program);
      }
    }
    
    // Apply role filter
    final filteredActive = activePrograms.where((program) {
      switch (_selectedRoleFilter) {
        case 'Host': return program.isHost;
        case 'Listener': return !program.isHost;
        default: return true;
      }
    }).toList();
    
    final filteredExpired = expiredPrograms.where((program) {
      switch (_selectedRoleFilter) {
        case 'Host': return program.isHost;
        case 'Listener': return !program.isHost;
        default: return true;
      }
    }).toList();
    
    // Sort active programs by date and time (upcoming first)
    filteredActive.sort((a, b) {
      final aStartTime = _parseStartTime(a.date, a.time);
      final bStartTime = _parseStartTime(b.date, b.time);
      return aStartTime.compareTo(bStartTime); // Ascending order (earliest first)
    });
    
    // Sort expired programs by date and time (newest first)
    filteredExpired.sort((a, b) {
      final aStartTime = _parseStartTime(a.date, a.time);
      final bStartTime = _parseStartTime(b.date, b.time);
      return bStartTime.compareTo(aStartTime); // Descending order (newest first)
    });
    
    final allPrograms = [...filteredActive, ...filteredExpired];
    
    if (allPrograms.isEmpty) {
      return Center(child: Text('No subscriptions found'));
    }
    
    return RefreshIndicator(
      onRefresh: _loadSubscriptions,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: allPrograms.length,
        itemBuilder: (context, index) {
          final program = allPrograms[index];
          final isExpired = isProgramExpired(program.date, program.time);
          final isStarted = !isExpired && isProgramStarted(program.date, program.time, program.bookingId!);
          final hostJoined = _hostHasJoined[program.bookingId] ?? false;
          final restarting = !program.isHost && isStarted && !hostJoined;

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isExpired ? Colors.grey : Colours.primarycolour,
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        program.programName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.grey : Colors.black,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.grey[300] : 
                                 program.isHost ? Colours.seachbarcolour : Colours.seachbarcolour,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          program.isHost ? 'Host' : 'Listener',
                          style: TextStyle(
                            color: isExpired ? Colors.grey[600] : 
                                   program.isHost ? Colours.brownColour : Colours.primarycolour,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Host: ${program.host?.isNotEmpty == true ? program.host! : "Self"}',
                    style: TextStyle(
                      color: isExpired ? Colors.grey : Colors.grey.shade600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${program.date} • ${program.time}',
                    style: TextStyle(
                      color: isExpired ? Colors.grey : Colors.grey.shade600),
                  ),
                  if (isExpired)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Session completed',
                        style: TextStyle(
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (!isExpired) SizedBox(height: 12),
                  if (!isExpired)
                    Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton(
    onPressed: () => _handleProgramAction(program),
    style: ElevatedButton.styleFrom(
      backgroundColor: program.isHost 
          ? (_isRestart ? Colours.brownColour : Colours.brownColour) 
          : Colours.primarycolour,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      program.isHost 
          ? (_isRestart ? 'Restart Session' : 'Start Session')
          : 'Join Session',
      style: TextStyle(color: Colors.white),
    ),
  ),
),
                  if (!isExpired && !program.isHost && isStarted && !hostJoined)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Waiting for host to start...',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }),
),
            ],
          ),
        ],
      ),
    );
  }
DateTime _parseProgramTime(String date, String timeStr) {
    try {
      final combined = "$date ${timeStr.trim()}";
      print("🔧 Parsing: $combined");
      final format = DateFormat("yyyy-MM-dd hh:mm a");
      return format.parseStrict(combined);
    } catch (e) {
      print("❌ Failed parsing: $e");
      throw FormatException("Invalid date/time: $date $timeStr");
    }
  }
void showStartTimePopup(String startTime, String date) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismiss on outside tap or back button
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Session Not Started",
          style: TextStyle(
            fontSize: 22,         // Bigger font for title
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "The session starts at $startTime on $date.",
          style: TextStyle(
            fontSize: 18,        // Bigger font for content
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Only closes dialog on OK tap
            child: Text(
              "OK",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      );
    },
  );
}


// Add these at the class level
bool _isRejoinInProgress = false;
bool _isDialogShowing = false;
Map<String, dynamic>? _cachedRestartResult; 

void showRejoinDialog(
  int userId,
  int bookingId,
  String programTime,
  String programDate,
  String programType,
) {
  if (_isDialogShowing || _cachedRestartResult == null) return;

  final data = _cachedRestartResult!['response'];
  if (data == null) return;

  // Log the response data to debug
  print('Dialog Data: $data');

  _isDialogShowing = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Session Failed'),
        content: Text('Would you like to rejoin the session?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              setState(() {
                _isDialogShowing = false; // Reset dialog flag
              });
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Rejoin'),
            onPressed: () async {
              setState(() {
                _isDialogShowing = false; // Reset dialog flag
              });
              Navigator.of(context).pop();

              if (!mounted) return;

              await Future.delayed(Duration(milliseconds: 300));

 Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoCallPage(
          userId: userId,
          channelName: data['channel_name'],
          token: data['token'],
          uid: data['agora_uid'],
          appId: "daed82b7feea4990bf7fb43d9addd091",
          programType: programType,
          isCaller: true,
          sessionId: data['new_session_id'] ?? _sessionId!,
           isRestart: _isRestart,
        ),
      ),
    );
  debugPrint("🎫 Agora token from server: ${data['token']}");
debugPrint("📺 Channel: ${data['channel_name']}");
debugPrint("👤 Agora UID: ${data['agora_uid']}");

  },
  
),
        ],
      );
    },
  ).then((_) {
    setState(() {
      _isDialogShowing = false; 
    });
  });
}
String formatDate(String rawDate) {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(rawDate);
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }
Future<void> handleProgramStart(
  int userId,
  int bookingId,
  String programTime,
  String programDate,
  String programType,
) async {
  if (_isRejoinInProgress) return;

  try {
    _isRejoinInProgress = true;
    setState(() {
      _isLoading = true;
      _isRestart = false; // Reset restart flag
    });

    // Time validation
    final parts = programTime.split('-');
    if (parts.length != 2) throw FormatException("Invalid time range format");
    
    final startTimeStr = parts[0].trim();
    final startDateTime = _parseProgramTime(programDate, startTimeStr);
    final now = DateTime.now();

    if (now.isBefore(startDateTime)) {
      showStartTimePopup(startTimeStr, formatDate(programDate));
      return;
    }

    // Try to rejoin existing session first
    if (_sessionId != null) {
      print('Attempting to rejoin session $_sessionId');
      setState(() => _isRestart = true); // Set restart flag
      
      final restartResult = await ApiService.restartCall(userId, _sessionId!);
      print('Rejoin API Result: $restartResult');

      if (restartResult != null) {
        final responseData = restartResult['response'] ?? restartResult;
        
        if (restartResult['status_code'] == 200 || 
            (restartResult['status_code'] == null && responseData['channel_name'] != null)) {
          // Successful rejoin
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => VideoCallPage(
                userId: userId,
                channelName: responseData['channel_name'],
                token: responseData['token'],
                uid: responseData['agora_uid'],
                appId: "daed82b7feea4990bf7fb43d9addd091",
                programType: programType,
                isCaller: true,
                sessionId: responseData['new_session_id'] ?? _sessionId!,
                isRestart: _isRestart, // Pass restart flag to call page
              ),
            ));
          return;
        }
      }
    }

    // If no existing session or rejoin failed, start new session
    print('Starting new call...');
// If no existing session or rejoin failed, start new session
print('Starting new call...');
final result = await ApiService.startCall(
  userId: userId,
  bookingId: bookingId,
  callType: programType,
);
print('Start Call API Result: $result');

if (!mounted) return;

// 👇 Set _isRestart based on API response
if (result?['wasRestarted'] == true) {
  setState(() => _isRestart = true);
} else {
  setState(() => _isRestart = false);
}

if (result == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to start session. Please try again.')),
  );
  return;
}

    
    final responseData = result['response'] ?? result;
    final statusCode = result['status_code'] ?? 200;
    
    if (statusCode != 200 || responseData['channel_name'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 
                          responseData['error'] ?? 
                          'Failed to start session')),
      );
      return;
    }
    
    _sessionId = responseData['session_id'] ?? responseData['new_session_id'];
    await Future.delayed(Duration(milliseconds: 300));
    
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoCallPage(
          userId: userId,
          channelName: responseData['channel_name'],
          token: responseData['token'],
          uid: responseData['agora_uid'],
          appId: "daed82b7feea4990bf7fb43d9addd091",
          programType: programType,
          isCaller: true,
          sessionId: _sessionId!,
          isRestart: _isRestart, // Pass restart flag to call page
        ),
    ));
  } catch (e) {
    print('Error in handleProgramStart: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } finally {
    _isRejoinInProgress = false;
    if (mounted) setState(() => _isLoading = false);
  }
}
Future<void> handleJoinCall(int userId, int? sessionId) async {
  if (sessionId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session ID not available. Please wait.')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final data = await ApiService.joinCall(
      userId: userId,
      sessionId: sessionId,
    );

    if (!mounted) return;

    print('Join Call Response: $data');

    if (data == null || data['status_code'] != 200 || data['response'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data?['error'] ?? 'Failed to join session. Please try again.'),
        ),
      );
      return;
    }

    // Extract the nested response object
    final response = data['response'] as Map<String, dynamic>;

    final channelName = response['channel_name'] as String?;
    final token = response['token'] as String?;
    final uid = int.tryParse(response['agora_uid']?.toString() ?? '') ?? -1;
    final callType = response['call_type'] as String?;

    print('Debug => Channel: $channelName, Token: $token, UID: $uid');

    if (channelName == null || token == null || uid == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing call details from server.')),
      );
      return;
    }

 Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoCallPage(
               userId :userId,
          channelName: channelName,
          token: token,
          uid: uid,

          appId: "daed82b7feea4990bf7fb43d9addd091",
          programType: callType,
          isCaller: false,
          sessionId: sessionId,
      isRestart: _isRestart,
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error joining call: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining: ${e.toString()}')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  @override
  void dispose() {
    super.dispose();
  }
}