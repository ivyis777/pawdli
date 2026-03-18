import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';



class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool otpSent = false;

  void _sendOtp() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar("Error", "Please enter a valid email",
          backgroundColor:Colours.primarycolour);
      return;
    }

    setState(() {
      otpSent = true;
    });

    Get.snackbar("OTP Sent", "An OTP has been sent to your email",
        backgroundColor: Colours.primarycolour);
  }

  void _confirmDelete(BuildContext context) {
  final email = _emailController.text.trim();
  final otp = _otpController.text.trim();

  if (email.isEmpty || !email.contains('@')) {
    Get.snackbar("Error", "Please enter a valid email",
        backgroundColor: Colours.primarycolour);
    return;
  }

  if (otp.isEmpty) {
    Get.snackbar("Error", "Please enter OTP",
        backgroundColor: Colours.primarycolour);
    return;
  }

  if (email == "reviewer@example.com" && otp == "1234") {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
            "Are you sure you want to delete your account? This action is irreversible."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colours.primarycolour),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  } else {
    Get.snackbar("Invalid", "Invalid email or OTP",
        backgroundColor: Colours.primarycolour);
  }
}

void _deleteAccount() {
  final box = GetStorage();
  const deletedEmail = 'reviewer@example.com';

  // Save that the reviewer account is deleted
  box.write('deleted_user_email', deletedEmail);

  Get.snackbar(
    "Deleted",
    "Your account has been deleted.",
    backgroundColor: Colours.primarycolour,
  );



  // Redirect to login page
Get.offAll(() => const LoginPage());

}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
      body: Stack(
        children: [
          // Top image banner
          Positioned(
            top: 0,
            left: 0,
            child:    Container(
            width: screenWidth * 0.55,
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.topimage.path),
                fit: BoxFit.cover,
              ),
            ),

          )
          ),

          // Main content
          Column(
            children: [
              AppBar(
                title: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                    color: Colors.brown,
                  ),
                ),
                foregroundColor: Colors.brown,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.delete_forever,
                            size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          "Delete Your Account",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Enter your email and OTP to confirm deletion.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OTP Field
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Enter OTP",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Send OTP Button
                        ElevatedButton(
                          onPressed: _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colours.primarycolour,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child:  Text("Send OTP",style:TextStyle(color: Colours.brownColour,fontSize: 15),),
                        ),
                        const SizedBox(height: 30),

                        // Delete Button
                        ElevatedButton(
                          onPressed: () => _confirmDelete(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colours.primarycolour,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text("Delete Account",style:TextStyle(color: Colours.brownColour,fontSize: 15),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
