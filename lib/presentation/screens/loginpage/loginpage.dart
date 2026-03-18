import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/form_validation/form_validation.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/logincontroller.dart';
import 'package:pawlli/data/controller/otpcontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/signuppage/signuppage.dart';
import 'package:pawlli/presentation/widgets/bottom%20bar/bottombar.dart';
import 'package:pawlli/presentation/widgets/commonui/commonui.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage ({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    bool _isProcessing = false;
  final _formKey1 = GlobalKey<FormState>();
late final OtpController otpController;

  List<TextEditingController> otpControllers = List.generate(4, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());
  LoginController logincontroller = Get.put(LoginController());
  TextEditingController _emailController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  
 Timer? _timer;
  int _start = 60;
  bool _isTimerVisible = false;
  bool _isGetOtpButtonDisabled = false;
  bool _isResendOtpButtonDisabled = false;
  bool _isInitialOtpRequest = true; 

    @override
void initState() {
  super.initState();
  otpController = Get.find<OtpController>(); // ✅ CREATE AGAIN AFTER LOGOUT
}

  void _startTimer() {
    setState(() {
      _isTimerVisible = true;
      _isGetOtpButtonDisabled = true;
      _isResendOtpButtonDisabled = true;
      _start = 60; 
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        timer.cancel();
        setState(() {
          _isTimerVisible = false;
          _isGetOtpButtonDisabled = false;
          _isResendOtpButtonDisabled = false;
        });
      }  if (mounted) { 
          setState(() {
            _start--;
          });
        }
      
    });
  }

  
  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    otpControllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final isSmallScreen = screenWidth < 600;

  return Scaffold(
      resizeToAvoidBottomInset: false, 
    backgroundColor: Colours.secondarycolour,
    body: Commonui(
      child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Form(
            key: _formKey1,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 20),
                child: Column(
                   mainAxisSize: MainAxisSize.min,
               
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Outer Card
                    Container(
                      width: isSmallScreen ? screenWidth * 0.90 : screenWidth * 0.75,
                      child: Card(
                        color: Colours.primarycolour,
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 9.0 : 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                Assets.images.pawllilogo.path,
                                height: isSmallScreen
                                    ? screenHeight * 0.15
                                    : screenHeight * 0.20,
                              ),
                              SizedBox(height: screenHeight * 0.015),

                              // Email Input
                              Container(
                                width: isSmallScreen ? screenWidth * 0.85 : screenWidth * 0.6,
                                child: Card(
                                  color: Colours.secondarycolour,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: TextFormField(
                                      validator: FormValidation.emailValidation,
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email',
                                        hintStyle:
                                            TextStyle(color: Colours.textColour),
                                        filled: true,
                                        fillColor: Colours.secondarycolour,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 10.0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: Colours.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                               Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (_isTimerVisible)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                                      child: Text(
                                        '00:${_start.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colours.black,
                                          fontFamily: FontFamily.Ubantu,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                              Container(
                                margin: EdgeInsets.fromLTRB(screenHeight* 0.18, 5, 5, 10),
                                child: TextButton(
                                onPressed: _isGetOtpButtonDisabled
                                  ? null
                                  : () async {
                                      if (_formKey1.currentState!.validate()) {
                                        setState(() {
                                          _isGetOtpButtonDisabled = true;
                                        });

                                        final result = await otpController.getOtpUser(
                                          email: _emailController.text,
                                          purpose: "login",
                                          isResend: !_isInitialOtpRequest,
                                        );

                                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                                        //   Get.snackbar(
                                        //     result.success ? "Success" : "Error",
                                        //     result.message,
                                        //     snackPosition: SnackPosition.TOP,
                                        //   );
                                        // });

                                        if (result.success) {

                                          Get.snackbar(
                                            "OTP Sent",
                                            "Please check your email for OTP",
                                            snackPosition: SnackPosition.TOP,
                                          );
                                          // ✅ EXISTING USER FLOW
                                          for (final controller in otpControllers) {
                                            controller.clear();
                                          }

                                          _startTimer();

                                          setState(() {
                                            _isInitialOtpRequest = false;
                                          });
                                        } else {
                                          final msg = result.message.toLowerCase();

                                          // ✅ HANDLE EMAIL NOT FOUND PROPERLY
                                          if (msg.contains('not found') || msg.contains('sign up')) {
                                            // ✅ SHOW ERROR FIRST
                                            Get.snackbar(
                                              "Account Not Found",
                                              result.message,
                                              snackPosition: SnackPosition.TOP,
                                            );

                                            // ✅ WAIT + NAVIGATE
                                            Future.delayed(const Duration(seconds: 1), () {
                                              Get.to(() => Signuppage(
                                                email: _emailController.text,
                                              ));
                                            });
                                          } else {
                                            // ❌ SHOW OTHER ERRORS
                                            Get.snackbar(
                                              "Error",
                                              result.message,
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          }

                                          setState(() {
                                            _isGetOtpButtonDisabled = false;
                                          });
                                        }
                                      }
                                    },


                                  child: Text(
                                    _isInitialOtpRequest ? "Get OTP" : 'Resend',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.Ubantu,
                                      color: _isGetOtpButtonDisabled ? Colors.grey : Colours.black,
                                    ),
                                  ),
                                ),
                              ),

                                ],
                              ),
                              SizedBox(height: 1),

                              // OTP Input
                              _buildOTPInputGrid(),

                              SizedBox(height: 15),

                              // Resend Section
                             

                              SizedBox(height: 3),

                          Container(
                            width: isSmallScreen ? screenWidth * 0.8 : screenWidth * 0.6,
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      if (_formKey1.currentState!.validate()) {
                                        setState(() {
                                          _isProcessing = true;
                                        });

                              final otp = otpControllers.map((controller) => controller.text).join();
                              final otpError = FormValidation.otpValidation(otp);
                              final enteredEmail = _emailController.text.trim();

                              // Static test credentials
                              const String testReviewerEmail = 'reviewer@example.com';
                              const String testReviewerOtp = '1234';

                              final box = GetStorage();
                              final deletedEmail = box.read('deleted_user_email');

                              if (otpError != null) {
                                Get.snackbar(
                                  "Login Failed",
                                  otpError,
                                  snackPosition: SnackPosition.TOP,
                                  colorText: Colours.brownColour,
                                  messageText: Center(
                                    child: Text(
                                      otpError,
                                      style: TextStyle(
                                        color: Colours.brownColour,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  backgroundColor: Colours.primarycolour,
                                );
                                setState(() {
                                  _isProcessing = false;
                                });
                              } 
                              // 🔐 If reviewer@example.com is marked deleted
                              else if (enteredEmail == testReviewerEmail &&
                                      otp == testReviewerOtp &&
                                      deletedEmail == testReviewerEmail) {
                                Get.snackbar(
                                  "Account Deleted",
                                  "This account has been deleted. Please contact ivyisark@gmail.com.",
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colours.primarycolour,
                                  colorText: Colours.brownColour,
                                  duration: const Duration(seconds: 4),
                                );
                                setState(() {
                                  _isProcessing = false;
                                });
                              } 
                              else {
                                try {
                                  String? fcmToken;
                                  try {
                                    fcmToken = await FirebaseMessaging.instance.getToken();
                                    print("📱 FCM Token: $fcmToken");
                                  } catch (e) {
                                    print("⚠️ Failed to get FCM token: $e");
                                    fcmToken = '';
                                  }

                                  final result = await logincontroller.loginWithOtp(
                                    email: enteredEmail,
                                    otp: otp,
                                  );

                                  if (!mounted) return;

                                  // ✅ SAFE snackbar (LoginPage = use ScaffoldMessenger)
                                  Get.snackbar(
                                    result.success ? "Success" : "Error",
                                    result.message,
                                    snackPosition: SnackPosition.TOP, // 👈 THIS MAKES IT TOP
                                    backgroundColor: Colors.transparent,
                                    colorText: Colors.black,
                                    margin: const EdgeInsets.all(10),
                                    duration: const Duration(seconds: 2),
                                  );

                                  if (result.success) {
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    Get.offAll(() => MainLayout());
                                  }
                                } finally {
                                  setState(() {
                                    _isProcessing = false;
                                  });
                                }
                              }
                            }
                          },
                            child: _isProcessing
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colours.secondarycolour),
                                  )
                                : Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontFamily.Ubantu,
                                      color: Colours.secondarycolour,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(
                                screenWidth * (isSmallScreen ? 0.6 : 0.4),
                                56,
                              ),
                              backgroundColor: Colours.brownColour,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),



                              SizedBox(height: 9),

                              // // Sign Up Section
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Text(
                              //       "Don't have an account?",
                              //       style: TextStyle(
                              //         color: Colours.black,
                              //         fontWeight: FontWeight.w400,
                              //         fontFamily: FontFamily.Ubantu,
                              //         fontSize: isSmallScreen ? 15: 20,
                              //       ),
                              //     ),
                              //     TextButton(
                              //       onPressed: () {
                              //         Get.to(Signuppage());
                              //       },
                              //       child: Text(
                              //         'Sign up',
                              //         style: TextStyle(
                              //           color: Colours.black,
                              //           fontFamily: FontFamily.Ubantu,
                              //           fontSize: isSmallScreen ? 16 : 20,
                              //           fontWeight: FontWeight.w500,
                              //           decoration: TextDecoration.underline,
                              //         ),
                              //       ),
                              //     )
                              //   ],
                              // ),

                              // // Terms and Privacy
                              // SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "By continuing, you agree to our",
                                    style: TextStyle(
                                      color: Colours.textColour,
                                      fontFamily: FontFamily.Ubantu,
                                      fontSize: isSmallScreen ? 13 : 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                     SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse(
                                          "https://www.pawlli.com/terms-and-conditions/"));
                                    },
                                    child: Text(
                                      "Terms of use",
                                      style: TextStyle(
                                        color: Colours.darkgreyColour,
                                        decoration: TextDecoration.underline,
                                        fontFamily: FontFamily.Ubantu,
                                        fontSize: isSmallScreen ? 13: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "and",
                                    style: TextStyle(
                                      color: Colours.textColour,
                                      fontFamily: FontFamily.Ubantu,
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                       SizedBox(width: 5,),
                                  GestureDetector(
                                    onTap: () {
                                      launchUrl(Uri.parse(
                                          "https://www.pawlli.com/privacy-policy/"));
                                    },
                                    child: Text(
                                      " Privacy policy",
                                      style: TextStyle(
                                        color: Colours.darkgreyColour,
                                        decoration: TextDecoration.underline,
                                        fontFamily: FontFamily.Ubantu,
                                        fontSize: isSmallScreen ? 14 : 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
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
    ),
  );
}




  Widget _buildOTPInputGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            controller: otpControllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
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
