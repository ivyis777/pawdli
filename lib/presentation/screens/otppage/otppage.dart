import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/logincontroller.dart';
import 'package:pawlli/data/controller/otpcontroller.dart';
import 'package:pawlli/data/controller/signcontroller.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/widgets/commonui/commonui.dart';

class OTPPage extends StatefulWidget {
  final String email;
  final String username;
  final String mobile;
  final String authType; // signup or login

  const OTPPage({
    required this.email,
    required this.username,
    required this.mobile,
    required this.authType,
    super.key,
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  bool _isProcessing = false;

  final OtpController otpController = Get.find<OtpController>();
  final SignupController signupController = Get.find<SignupController>();

  List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    focusNodes[0].requestFocus();
    startTimer();
  }

  void startTimer() {
    _start = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String? otpValidation(String text) {
    if (text.isEmpty) return 'Please enter your OTP';
    if (text.length != 4 || int.tryParse(text) == null) {
      return 'OTP must be a 4-digit number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
      body: Commonui(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 40,
              vertical: isSmallScreen ? 24 : 80,
            ),
            child: Card(
              color: Colours.primarycolour,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 25 : 27,
                        fontWeight: FontWeight.w500,
                        color: Colours.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Check your mail. We have sent you the',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 18,
                        color: Colours.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PIN for ${widget.email}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colours.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildOTPInputGrid(),
                    const SizedBox(height: 20),
                    Text(
                      '00:${_start.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colours.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the OTP?",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: Colours.black,
                          ),
                        ),
                        TextButton(
                          onPressed: _start == 0
                              ? () async {
                                  final result = await otpController.getOtpUser(
                                    email: widget.email,
                                    username: widget.authType == "signup" ? widget.username : null,
                                    mobile: widget.authType == "signup" ? widget.mobile : null,
                                    purpose: widget.authType,
                                    isResend: true,
                                  );

                                  // ✅ Show snackbar safely from UI
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Get.snackbar(
                                      result.success ? "Success" : "Error",
                                      result.message,
                                      snackPosition: SnackPosition.TOP,
                                    );
                                  });

                                  if (result.success) {
                                    for (final c in otpControllers) {
                                      c.clear();
                                    }
                                    startTimer();
                                  }
                                }
                              : null,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: _start == 0
                                  ? Colours.black
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              setState(() => _isProcessing = true);

                              try {
                                final otp = otpControllers
                                    .map((c) => c.text)
                                    .join();

                                final error = otpValidation(otp);
                             if (error != null) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Get.snackbar(
                                        "Error",
                                        error,
                                        snackPosition: SnackPosition.TOP,
                                      );
                                    });
                                    return;
                                  }
                                if (widget.authType == "signup") {
                                  await signupController.getSignupUser(
                                    username: widget.username,
                                    email: widget.email,
                                    mobile: widget.mobile,
                                    otp: otp,
                                  );
                                } else {
                                  await Get.find<LoginController>()
                                      .loginWithOtp(
                                    email: widget.email,
                                    otp: otp,
                                  );
                                }
                              } finally {
                                setState(() => _isProcessing = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 50),
                        backgroundColor: Colours.brownColour,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isProcessing
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colours.secondarycolour),
                            )
                          : Text(
                              widget.authType == "signup"
                                  ? "Register"
                                  : "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: FontFamily.Ubantu,
                                color: Colours.secondarycolour,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPInputGrid() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final boxSize = isSmallScreen ? 55.0 : 60.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: boxSize,
          height: boxSize,
          child: TextField(
            controller: otpControllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context)
                    .requestFocus(focusNodes[index + 1]);
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context)
                    .requestFocus(focusNodes[index - 1]);
              }
            },
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colours.secondarycolour,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
