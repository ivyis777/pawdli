import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/cartviewcontroller.dart';
import 'package:pawlli/data/controller/petslistcontroller.dart';
import 'package:pawlli/data/controller/reelitemcontroller.dart';
import 'package:pawlli/presentation/screens/good%20bye%20buddy/goodbyebudddy.dart';
import 'package:pawlli/presentation/screens/homepage/homepage.dart';
import 'package:pawlli/presentation/screens/mychat/chat.dart';
import 'package:pawlli/presentation/screens/pet%20Radio/petradio.dart';
import 'package:pawlli/presentation/screens/pet%20store/pet_cart.dart';
import 'package:pawlli/presentation/screens/potcast/potcast.dart';

class MainLayout extends StatefulWidget {
   MainLayout({super.key});

  @override
  _MainLayoutState createState() => _MainLayoutState();

}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final CartController cartController = Get.find<CartController>();

  late List<GlobalKey<NavigatorState>> navigatorKeys;
  late List<Widget> _pages;

@override
void initState() {
  super.initState();

  // ✅ CREATE CONTROLLERS ONCE (AFTER LOGIN / SIGNUP)
  if (!Get.isRegistered<ReelsController>()) {
    Get.put(ReelsController(), permanent: true);
  }

  if (!Get.isRegistered<Petslistcontroller>()) {
    Get.put(Petslistcontroller(), permanent: true);
  }

  navigatorKeys = List.generate(5, (index) => GlobalKey<NavigatorState>());
}


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      Navigator(
        key: navigatorKeys[0],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => const HomePage()),
      ),
      Navigator(
        key: navigatorKeys[1],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => const Petradio()),
      ),
      Navigator(
        key: navigatorKeys[2],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) => const Goodbyebudddy()),
      ),
      Navigator(
        key: navigatorKeys[3],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) =>  CartPage()),
      ),
      Navigator(
        key: navigatorKeys[4],
        onGenerateRoute: (routeSettings) =>
            MaterialPageRoute(builder: (context) =>  ChatPage()),
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      if (navigatorKeys[index].currentState!.canPop()) {
        navigatorKeys[index]
            .currentState!
            .popUntil((route) => route.isFirst);
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
  final currentNavigatorState = navigatorKeys[_selectedIndex].currentState;

  if (currentNavigatorState != null && currentNavigatorState.canPop()) {
    currentNavigatorState.pop();
    return false;
  }

  final shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent accidental dismissal
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Icon(Icons.exit_to_app, size: 48, color: Colours.brownColour,),
            const SizedBox(height: 16),
            const Text(
              'Exit App?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to exit the app?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colours.brownColour,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colours.brownColour,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );

  return shouldExit ?? false;
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          color: Colours.primarycolour,
          buttonBackgroundColor: Colours.brownColour,
          height: 60,
          animationDuration: const Duration(milliseconds: 300),
          items: [
            const Icon(FontAwesomeIcons.home, color: Colors.white, size: 24),
            const Icon(FontAwesomeIcons.radio, color: Colors.white, size: 24),
            Image.asset(
              'assets/images/goodbyebuddy.png',
              width: 50,
              height: 50,
            ),
           Stack(
  clipBehavior: Clip.none,
  children: [
    const Icon(
      FontAwesomeIcons.cartArrowDown,
      color: Colors.white,
      size: 24,
    ),

    // 🔴 CART BADGE
    Obx(() {
  final count = cartController.cartItems.length;

  if (count == 0) {
    return const SizedBox.shrink();
  }

  return Positioned(
    top: -8,
    right: -10,
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 15,
        minHeight: 15,
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}),

  ],
),

            const Icon(FontAwesomeIcons.message,
                color: Colors.white, size: 24),
          ],
          index: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
