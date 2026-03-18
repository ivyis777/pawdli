import 'package:flutter/material.dart';
import 'package:pawlli/core/form_validation/form_validation.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get.dart';
import 'package:pawlli/data/controller/otpcontroller.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:pawlli/presentation/screens/otppage/otppage.dart';
import 'package:pawlli/presentation/widgets/commonui/commonui.dart';


class Signuppage extends StatefulWidget {
  final String? email;  
  const Signuppage({super.key, this.email});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
    bool _isProcessing = false;
    final otpController = Get.find<OtpController>();
  final _formKey1 = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  // final otpController = Get.put(OtpController());
  String fullPhoneNumber = ''; // Add this in your state

@override
void initState() {
  super.initState();

  // 👇 AUTO FILL EMAIL FROM LOGIN PAGE
  if (widget.email != null) {
    _emailController.text = widget.email!;
  }
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
 resizeToAvoidBottomInset: false,
      backgroundColor: Colours.secondarycolour,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Commonui(
            child: SingleChildScrollView(
                     keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallScreen ? 30 : 50),
                      // Form Card
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colours.primarycolour,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey1,
                            child: Column(
                              children: [
                                // Title
                                Text(
                                  "Let’s Register",
                                  style: TextStyle(
                                    color: Colours.black,
                                    fontFamily: FontFamily.Ubantu,
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  validator: FormValidation.nameValidation,
                                  decoration: InputDecoration(
                                    hintText: "User Id",
                                    hintStyle: TextStyle(color: Colours.textColour),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                                    filled: true,
                                    fillColor: Colours.secondarycolour,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(Icons.person_outline, color: Colours.black),
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  validator: FormValidation.emailValidation,
                                  decoration: InputDecoration(
                                    hintText: "Email Id",
                                    hintStyle: TextStyle(color: Colours.textColour),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                                    filled: true,
                                    fillColor: Colours.secondarycolour,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(Icons.email_outlined, color: Colours.black),
                                  ),
                                ),
                                SizedBox(height: 20),
                               
                              IntlPhoneField(
                                  decoration: InputDecoration(
                                    hintText: 'Phone Number',
                                    hintStyle: TextStyle(color: Colours.textColour),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                                    filled: true,
                                    fillColor: Colours.secondarycolour,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: Icon(Icons.phone, color: Colours.black),
                                  ),
                                  initialCountryCode: 'IN',
                                  onChanged: (phone) {
                                    // Save full number with country code, e.g. +91 9876543210
                                    fullPhoneNumber = phone.completeNumber;
                                  },
                                  validator: (phone) {
                                    if (phone == null || phone.number.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (phone.number.length != 10) {
                                      return 'Phone number must be 10 digits';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 20),
                    
                                Center(
                                  child: ElevatedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : () async {
                                          if (_formKey1.currentState!.validate()) {
                                            setState(() => _isProcessing = true);

                                            try {
                                              final result = await otpController.getOtpUser(
                                                email: _emailController.text,
                                                username: _nameController.text,
                                                mobile: fullPhoneNumber,
                                                purpose: "signup",
                                                isResend: false,
                                              );

                                              // WidgetsBinding.instance.addPostFrameCallback((_) {
                                              //   Get.snackbar(
                                              //     result.success ? "Success" : "Error",
                                              //     result.message,
                                              //     snackPosition: SnackPosition.TOP,
                                              //   );
                                              // });

                                              if (result.success) {
                                                // ✅ SUCCESS → GO TO OTP PAGE
                                                Get.to(
                                                  OTPPage(
                                                    email: _emailController.text,
                                                    username: _nameController.text,
                                                    mobile: fullPhoneNumber,
                                                    authType: "signup",
                                                  ),
                                                );
                                              } else {
                                                final msg = result.message.toLowerCase();

                                                if (msg.contains('email already')) {
                                                  Get.snackbar(
                                                    "Error",
                                                    "Email already registered. Please login.",
                                                    snackPosition: SnackPosition.TOP,
                                                  );
                                                } 
                                                else if (msg.contains('username already')) {
                                                  Get.snackbar(
                                                    "Error",
                                                    "Username already exists. Try different name.",
                                                    snackPosition: SnackPosition.TOP,
                                                  );
                                                } 
                                                else if (msg.contains('mobile already')) {
                                                  Get.snackbar(
                                                    "Error",
                                                    "Mobile number already registered.",
                                                    snackPosition: SnackPosition.TOP,
                                                  );
                                                } 
                                                else {
                                                  // ✅ DEFAULT MESSAGE FROM API
                                                  Get.snackbar(
                                                    "Error",
                                                    result.message,
                                                    snackPosition: SnackPosition.TOP,
                                                  );
                                                }
                                              }
                                            } finally {
                                              setState(() => _isProcessing = false);
                                            }
                                          }
                                        },
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: Size(
                                              screenWidth * (isSmallScreen ? 0.6 : 0.4),
                                              54,
                                            ),
                                            backgroundColor: Colours.brownColour,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                          child: _isProcessing
                                              ? CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(Colours.secondarycolour),
                                                )
                                              : Text(
                                                  "Get OTP",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: FontFamily.Ubantu,
                                                    color: Colours.secondarycolour,
                                                  ),
                                                ),
                                        )

                                        ),

                                SizedBox(height: 1),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account ? ",
                                      style: TextStyle(
                                        color: Colours.textColour,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: FontFamily.Ubantu,
                                        fontSize: isSmallScreen ? 14 : 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.to(LoginPage()),
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Colours.darkgreyColour,
                                          fontFamily: FontFamily.Ubantu,
                                          fontSize: isSmallScreen ?  14 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
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
          );
        },
      ),
    );
  }
}
