import 'package:flutter/material.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:pawlli/presentation/widgets/commonui/commonui.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}


 class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    navigationOnBoarding();
  }

  Future<void> navigationOnBoarding() async {
  
    await Future.delayed(const Duration(milliseconds: 2500));
   
    Get.offAll(() => const LoginPage()); 
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Commonui(
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
   
            double imageWidth = screenWidth * 4.2;  
            double imageHeight = imageWidth * 4;  

            if (screenHeight < 600) {
              imageWidth = screenWidth * 4.2;  
              imageHeight = imageWidth * 4;  
            }

            return Image.asset(
              Assets.images.pawllilogo.path,
              height: imageHeight,
              width: imageWidth,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading image: $error");
                return const Center(child: Text('Error loading image'));
              },
            );
          },
        ),
      ),
    );
  }
}
