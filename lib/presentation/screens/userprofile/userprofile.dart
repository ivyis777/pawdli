import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/LocalStorageConstants.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/core/storage_manager/local_storage.dart';
import 'package:pawlli/data/controller/getuserprofilecontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/Pet%20Adoption/pet_adt_list.dart';
import 'package:pawlli/presentation/screens/delete%20account/delete_account.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/loginpage/loginpage.dart';
import 'package:pawlli/presentation/screens/my%20pets/my%20pets.dart';
import 'package:pawlli/presentation/screens/mysusbcriptions/subscriptionpage.dart';
import 'package:pawlli/presentation/screens/payments%20page/paymentpage.dart';
import 'package:pawlli/presentation/screens/personalinfopage/personalinfopage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pawlli/presentation/screens/pet%20store/myorders.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
    final bool fromUpdateFlow;
     const ProfilePage({  
    Key? key,
       this.fromUpdateFlow = false,
  }) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
    final userDetailsController = Get.put<UserProfileController >(UserProfileController ());
  File? _profileImage; 
bool isNotificationEnabled = true;
final Uri termsUrl = Uri.parse('https://www.pawlli.com/terms-and-conditions/');
final Uri privacyUrl = Uri.parse('https://www.pawlli.com/privacy-policy/');
 Future<void> logout() async {
  LocalStorage.clearTokens();   // access + refresh
  // Get.deleteAll(force: true);
  Get.offAll(() => LoginPage());
}

@override
  void initState() {
    super.initState();
    fetchUserDetails();
  }
  void fetchUserDetails() async {
    final box = GetStorage();
    int? userId = box.read(LocalStorageConstants.userId);
    if (userId != null) {
      await userDetailsController.loadUserProfile(userId);
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
     final user = userDetailsController.userProfile.value;
    final String? profilePic = user?.profilePicture;
    final String fullImageUrl = profilePic != null && profilePic.isNotEmpty
        ? profilePic
        : '';
  return WillPopScope(
      onWillPop: () async {
        if (widget.fromUpdateFlow) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
          return false;
        }
        return true;
      },
  child:  Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenWidth * 0.55,
            height: screenHeight * 0.10,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.topimage.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  'User Profile',
                  style: TextStyle(
                    fontSize: screenHeight * 0.035,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.brownColour,
                  ),
                ),
                foregroundColor: Colours.brownColour,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Center(
                    child: GestureDetector(
                      onTap: () {
                        if (fullImageUrl.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullScreenProfileImage(
                                imageUrl: fullImageUrl,
                              ),
                            ),
                          );
                        }
                      },
                      child: CircleAvatar(
                        radius: 80.0,
                        backgroundImage: fullImageUrl.isNotEmpty
                            ? CachedNetworkImageProvider(fullImageUrl)
                            : null,
                        backgroundColor: Colors.grey[200],
                        child: fullImageUrl.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                      SizedBox(height: 10),
                     Center(
                      child: Text(
                        (user?.name?.isEmpty ?? true) ? (user?.username ?? '') : user!.name!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                      ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[
                          _buildSection(
                            context,
                            title: 'Personal Info',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PersonalInfoPage()),
                              );
                              fetchUserDetails();
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'My Pets',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPets()));
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'My Payment',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MypaymentsPage()),
                              );
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'My Subscription',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SubscriptionPage()),
                              );
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'My Orders',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => OrdersPage()),
                              );
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'Adoptions',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AdoptionPets()),
                              );
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'Delete Account',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DeleteAccountPage()),
                              );
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'Terms and Conditions',
                            onTap: () async {
                              if (await canLaunchUrl(termsUrl)) {
                                await launchUrl(termsUrl, mode: LaunchMode.externalApplication);
                              } else {
                                throw 'Could not launch $termsUrl';
                              }
                            },
                          ),

                          _buildSection(
                            context,
                            title: 'Privacy Policy',
                            onTap: () async {
                              if (await canLaunchUrl(privacyUrl)) {
                                await launchUrl(privacyUrl, mode: LaunchMode.externalApplication);
                              } else {
                                throw 'Could not launch $privacyUrl';
                              }
                            },
                          ),

                          SizedBox(height: 10),

                          Center(
                            child: ElevatedButton(
                              onPressed: logout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colours.brownColour,
                                fixedSize: Size(screenWidth * 0.8, screenHeight * 0.07),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: screenHeight * 0.025,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ]
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildSection(BuildContext context, {required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colours.primarycolour, Colours.primarycolour],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
          ),
        ),
      ),
    );
  }
}

class FullScreenProfileImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenProfileImage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const CircularProgressIndicator(color: Colors.white),
            errorWidget: (context, url, error) =>
                const Icon(Icons.image_not_supported, color: Colors.white, size: 60),
          ),
        ),
      ),
    );
  }
}
