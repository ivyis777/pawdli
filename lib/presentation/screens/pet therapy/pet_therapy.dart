import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/pettheraphycontroller.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/pet_therapy_slot.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class PetTherapy extends StatefulWidget {
  const PetTherapy({Key? key}) : super(key: key);

  @override
  State<PetTherapy> createState() => _PetTherapyState();
}

class _PetTherapyState extends State<PetTherapy> {
  DateTime _selectedDate = DateTime.now();
  late final PetTherapyController controller;

bool _showCalendar = false;
@override
void initState() {
  super.initState();
  controller = Get.put(PetTherapyController());
  controller.fetchPetTherapies(
    date: DateFormat('dd-MM-yyyy').format(_selectedDate),
  );
}




  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // final controller = Get.put(PetTherapyController());

    return Scaffold(
      backgroundColor: Colours.secondarycolour,
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
    'Pet Therapy',
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
  actions: [
    IconButton(
      icon: const Icon(Icons.calendar_today),
      color: Colours.brownColour,
      onPressed: () {
        setState(() {
          _showCalendar = !_showCalendar;
        });
      },
    ),
  ],
),

// 👇 Show selected date
Padding(
  padding: const EdgeInsets.only(top: 8.0),
  child: Text(
    'Selected Date: ${DateFormat.yMMMMd().format(_selectedDate)}',
    style: TextStyle(
      fontSize: screenHeight * 0.020,
      fontWeight: FontWeight.w500,
      fontFamily: FontFamily.Cairo,
      color: Colours.brownColour,
    ),
  ),
),

// 👇 Show calendar only when icon is tapped
if (_showCalendar)
  TableCalendar(
    firstDay: DateTime.utc(2020, 1, 1),
    lastDay: DateTime.utc(2030, 12, 31),
    focusedDay: _selectedDate,
    selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
  onDaySelected: (selectedDay, focusedDay) {
  setState(() {
    _selectedDate = selectedDay;
    _showCalendar = false;
  });

  // 🔑 Reload pets for this date
  final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDay);
  controller.fetchPetTherapies(date: formattedDate);
},

    calendarStyle: CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: Colours.primarycolour,
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        color: Colours.brownColour.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    ),
    headerStyle: HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
    ),
  ),



    // Pet list (only when calendar is hidden)
    if (!_showCalendar)
    Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pets.isEmpty) {
          return const Center(child: Text('No pets available'));
        }

        return ListView.builder(
          itemCount: controller.pets.length,
          itemBuilder: (context, index) {
            final pet = controller.pets[index];
            final backgroundImage = index.isEven
                ? Assets.images.yellowcard.path
                : Assets.images.browncard.path;

            return buildPetCard(
              context,
              screenWidth,
              screenHeight,
              pet,
              backgroundImage,
            );
          },
        );
      }),
    ),
  ],
),       
        ],
      ),
    );
  }

  Widget buildPetCard(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    dynamic pet,
    String backgroundImage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PetTherapySlot(
      petid: pet.id,
      selectedDate: _selectedDate, 
    ),
  ),
);

        },
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * 0.20,
              child: Image.asset(backgroundImage, fit: BoxFit.fill),
            ),
            Positioned(
              left: screenWidth * 0.07,
              top: screenHeight * 0.010,
              right: screenWidth * 0.30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name ?? "Unknown",
                    style: TextStyle(
                      color: Colours.secondarycolour,
                      fontFamily: FontFamily.Cairo,
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                
                  const SizedBox(height: 1),
                  Text(
                    pet.description ?? "No description",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colours.secondarycolour,
                      fontFamily: FontFamily.Cairo,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: screenWidth * 0.06,
                          color: Colours.secondarycolour),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pet.location ?? "Pawlli Office",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colours.secondarycolour,
                            fontFamily: FontFamily.Cairo,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Tap to book a session with this pet!",
                    style: TextStyle(
                      color: Colours.secondarycolour,
                      fontFamily: FontFamily.Cairo,
                      fontSize: screenWidth * 0.038,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          if (pet.image != null)
  Positioned(
    right: screenWidth * 0.08,
    bottom: screenHeight * 0.010,
    child: Column(
      children: [
        CircleAvatar(
          radius: screenWidth * 0.13,
          backgroundColor: Colors.transparent,
          child: CachedNetworkImage(
            imageUrl: pet.image!,
            imageBuilder: (context, imageProvider) => CircleAvatar(
              radius: screenWidth * 0.13,
              backgroundImage: imageProvider,
            ),
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageGalleryScreen(
  images: pet.galleryImageUrls,
),

              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shadowColor: Colors.black,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            'Images',
            style: TextStyle(
              color: Colours.secondarycolour,
              fontSize: screenWidth * 0.035,
              fontFamily: FontFamily.Cairo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  ),

          ],
        ),
      ),
    );
  }
}



class ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryScreen({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  void _nextPage() {
    if (_currentIndex < widget.images.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Gallery", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
  alignment: Alignment.center,
  children: [
    PageView.builder(
      controller: _controller,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemBuilder: (_, index) {
        return Center(
          child: InteractiveViewer(
  child: CachedNetworkImage(
  imageUrl: widget.images[index],
  fit: BoxFit.contain,
  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
  errorWidget: (context, url, error) => const Center(
    child: Icon(Icons.broken_image, color: Colors.white, size: 50),
  ),
),

),

        );
      },
    ),

    // ⬅️ Show Back only if not on first image
    if (_currentIndex > 0)
      Positioned(
        left: 10,
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 32, color: Colors.white),
          onPressed: _prevPage,
        ),
      ),

    // ➡️ Show Next only if not on last image
    if (_currentIndex < widget.images.length - 1)
      Positioned(
        right: 10,
        child: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 32, color: Colors.white),
          onPressed: _nextPage,
        ),
      ),
  ],
),

    );
  }
}
