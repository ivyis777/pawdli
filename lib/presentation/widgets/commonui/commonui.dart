import 'package:flutter/material.dart';
import 'package:pawlli/gen/assests.gen.dart';

class Commonui extends StatelessWidget {
  final Widget child;

  const Commonui({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // Top image
          Positioned(
            top: 0,
            left: -24,
            child: Image.asset(
              Assets.images.commonimagefirst.path,
              width: screenWidth * 0.42,
              height: screenHeight * 0.09,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Error loading first image'));
              },
            ),
          ),
          if (!isKeyboardOpen)
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                Assets.images.commonimagesecond.path,
                width: screenWidth,
                height: screenHeight * 0.11,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('Error loading second image'));
                },
              ),
            ),

          // Main content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isKeyboardOpen ? 20 : 0, 
              ),
              child: Center(child: child),
            ),
          ),
        ],
      ),
    );
  }
}