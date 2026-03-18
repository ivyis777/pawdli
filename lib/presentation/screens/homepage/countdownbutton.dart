import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/presentation/screens/reelspage/uploadreel.dart';
import '../../../data/controller/competition_controller.dart';

class CompetitionCountdownButton extends StatelessWidget {
  CompetitionCountdownButton({super.key});

  final CompetitionController controller =
      Get.find<CompetitionController>();

  /// Format countdown timer
  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${d.inDays} : "
        "${two(d.inHours % 24)} : "
        "${two(d.inMinutes % 60)} : "
        "${two(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      if (!controller.showButton) {
        return const SizedBox.shrink();
      }

      final competition = controller.activeCompetition.value!;
      final duration = controller.timeLeft.value;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: screenWidth * 0.14,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colours.primarycolour,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),

            /// Pick video and navigate
            onPressed: () async {
              final picker = ImagePicker();

              final pickedFile =
                  await picker.pickVideo(source: ImageSource.gallery);

              if (pickedFile == null) return;

              Get.to(() => AddDetailsPage(
                    videoFile: File(pickedFile.path),
                  ));
            },

            /// Button UI
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// Title from API
                  Text(
                    competition.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: screenWidth * 0.03),

                  /// Countdown Timer
                  Text(
                    _formatDuration(duration),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}