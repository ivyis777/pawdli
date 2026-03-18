import 'package:get/get.dart';
class VideoCallController extends GetxController {
  var isInCall = false;

  void startCall() {
    // logic to start or resume the call
    isInCall = true;
  }

  void endCall() {
    isInCall = false;
  }
}
