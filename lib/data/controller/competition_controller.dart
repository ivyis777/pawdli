import 'dart:async';
import 'package:get/get.dart';
import 'package:pawlli/core/auth/authservice.dart';
import 'package:pawlli/data/api%20service.dart';
import '../model/competition_model.dart';

class CompetitionController extends GetxController {
  // 🔥 REACTIVE VARIABLES
  final Rx<CompetitionModel?> activeCompetition = Rx<CompetitionModel?>(null);
  final Rx<Duration> timeLeft = Duration.zero.obs;
  

  Timer? _timer;

  // ---------------- SHOW BUTTON LOGIC ----------------
  bool get showButton {
    final competition = activeCompetition.value;

    if (competition == null) return false;
    if (!competition.isActive) return false;

    final now = DateTime.now();
    return now.isAfter(competition.startDateTime) &&
           now.isBefore(competition.endDateTime);
  }

  // ---------------- INIT ----------------
  @override
  void onInit() {
    super.onInit();
    print("🚀 CompetitionController onInit()");
    fetchCompetition();
  }

  // ---------------- FETCH COMPETITION ----------------
  Future<void> fetchCompetition() async {
    print("🟡 fetchCompetition() CALLED");

    try {
final ok = await AuthService.refreshTokenIfNeeded();
if (!ok) return;

final competitions = await ApiService.fetchCompetitionButton();
      print("🟡 API RESPONSE COUNT : ${competitions.length}");

      final now = DateTime.now();

      final validCompetitions = competitions.where((c) =>
          c.isActive &&
          now.isAfter(c.startDateTime) &&
          now.isBefore(c.endDateTime)
      ).toList();

      if (validCompetitions.isNotEmpty) {
        activeCompetition.value = validCompetitions.first;

        print("✅ ACTIVE COMPETITION SELECTED");
        print("🟢 Title : ${activeCompetition.value!.title}");

        _startCountdown();
      } else {
        print("❌ No active competition");
        activeCompetition.value = null;
      }
    } catch (e) {
      print("🔴 ERROR: $e");
      activeCompetition.value = null;
    }
  }

  // ---------------- COUNTDOWN ----------------
  void _startCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final competition = activeCompetition.value;
      if (competition == null) return;

      final remaining =
          competition.endDateTime.difference(DateTime.now());

      if (remaining.inSeconds <= 0) {
        timeLeft.value = Duration.zero;
        _timer?.cancel();
        activeCompetition.value = null;
      } else {
        timeLeft.value = remaining;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
