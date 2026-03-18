import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/slotcontroller.dart';
import 'package:pawlli/data/model/slotcreationmodel.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/bookslot/bookslot.dart';


class TimeSlotPage extends StatefulWidget {
  final String radioname;
  final int? radioid;
  const TimeSlotPage({super.key, required this.radioid, required this.radioname});

  @override
  State<TimeSlotPage> createState() => _TimeSlotPageState();
}

class _TimeSlotPageState extends State<TimeSlotPage> {
  final SlotController slotController = Get.put(SlotController());
  DateTime _selectedDate = DateTime.now();
  
  // Stores all selected slots across all dates: { "2023-10-01": {slotId1, slotId2}, "2023-10-02": {slotId3} }
  final Map<String, Set<int>> _selectedSlotsMap = {};
  
  // Stores the actual slot objects for all selected slots
  final List<Data> _allSelectedSlots = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchSlotsForSelectedDay();
  }

  void _fetchSlotsForSelectedDay() {
    if (widget.radioid == null) {
      print("radioid is null, cannot fetch slots");
      return;
    }
    
    String dayName = DateFormat('EEEE').format(_selectedDate);
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      slotController.fetchSlots(widget.radioid!, dayName, formattedDate);
    });
  }

  void _toggleSlotSelection(Data slot) {
    setState(() {
      final date = slot.date ?? DateFormat('yyyy-MM-dd').format(_selectedDate);
      final slotId = slot.slotId ?? 0;
      final amount = double.tryParse(slot.amount ?? '0') ?? 0.0;

      // Initialize date entry if not exists
      _selectedSlotsMap.putIfAbsent(date, () => {});

      if (_selectedSlotsMap[date]!.contains(slotId)) {
        // Remove selection
        _selectedSlotsMap[date]!.remove(slotId);
        _totalAmount -= amount;
        _allSelectedSlots.removeWhere((s) => s.slotId == slotId && s.date == date);
      } else {
        // Add selection
        _selectedSlotsMap[date]!.add(slotId);
        _totalAmount += amount;
        _allSelectedSlots.add(slot);
      }

      // Clean up empty dates
      if (_selectedSlotsMap[date]!.isEmpty) {
        _selectedSlotsMap.remove(date);
      }
    });
  }

  bool _isSlotSelected(Data slot) {
    final date = slot.date ?? DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _selectedSlotsMap[date]?.contains(slot.slotId) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(screenHeight * 0.12),
                    child: AppBar(
                      title: Text(
                        'Book Slots',
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.w600,
                          fontFamily: FontFamily.Cairo,
                          color: Colours.black,
                        ),
                      ),
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: [
                        IconButton(
                          icon: Icon(Icons.calendar_today, color: Colours.black),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null && pickedDate != _selectedDate) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _fetchSlotsForSelectedDay();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Date Selector
                  SizedBox(
                    height: screenHeight * 0.09,
                    child: ListView.builder(
                      key: ValueKey(_selectedDate),
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        DateTime dateToShow = _selectedDate.add(Duration(days: index)); 
                        bool isSelected = _selectedDate.day == dateToShow.day &&
                                        _selectedDate.month == dateToShow.month &&
                                        _selectedDate.year == dateToShow.year;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = dateToShow;
                              _fetchSlotsForSelectedDay();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            width: screenWidth * 0.17,
                            decoration: BoxDecoration(
                              color: isSelected ? Colours.brownColour : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${dateToShow.day}',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.015,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE').format(dateToShow),
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.020,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Selected Slots Summary
                  if (_allSelectedSlots.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Slots:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.018,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Wrap(
                            spacing: screenWidth * 0.02,
                            runSpacing: screenHeight * 0.01,
                            children: _allSelectedSlots.map((slot) {
                              return Chip(
                                label: Text(
                                  '${DateFormat('MMM d').format(DateTime.parse(slot.date!))}: ${slot.startTime}',
                                  style: TextStyle(fontSize: screenHeight * 0.015),
                                ),
                                backgroundColor: Colours.primarycolour.withOpacity(0.2),
                                deleteIcon: Icon(Icons.close, size: screenHeight * 0.018),
                                onDeleted: () => _toggleSlotSelection(slot),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Total Amount: ₹$_totalAmount',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenHeight * 0.018,
                              color: Colours.primarycolour,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Obx(() {
                    if (slotController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (slotController.slotList.isEmpty) {
                      return Center(
                        child: Text(
                          "No slots available for this date",
                          style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.grey),
                        ),
                      );
                    }
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = (constraints.maxWidth > 600) ? 4 : 3;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: screenWidth * 0.02,
                            mainAxisSpacing: screenHeight * 0.010,
                            childAspectRatio: 1.9,
                          ),
                          itemCount: slotController.slotList.length,
                          itemBuilder: (context, index) {
                            final slot = slotController.slotList[index];
                            bool isSelected = _isSlotSelected(slot);
                            bool isAvailable = slot.isAvailable ?? false;

                            return IgnorePointer(
                              ignoring: !isAvailable,
                              child: GestureDetector(
                                onTap: () => _toggleSlotSelection(slot),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.010,
                                    horizontal: screenWidth * 0.01,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colours.brownColour
                                        : (isAvailable ? Colors.white : Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colours.brownColour
                                          : isAvailable
                                              ? Colours.primarycolour
                                              : Colors.grey,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${slot.startTime} - ${slot.endTime ?? 'N/A'}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.01,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : isAvailable
                                                  ? Colors.black
                                                  : Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.003),
                                      Text(
                                        ' ₹ ${slot.amount}',
                                        style: TextStyle(
                                          fontSize: screenHeight * 0.014,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : isAvailable
                                                  ? Colors.black
                                                  : Colors.grey,
                                        ),
                                      ),
                                     
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _allSelectedSlots.isNotEmpty
                            ? () {
                                final slotIds = _allSelectedSlots.map((s) => s.slotId ?? 0).toList();
                                final dates = _allSelectedSlots.map((s) => s.date ?? DateFormat('yyyy-MM-dd').format(_selectedDate)).toList();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RadioProgramPage(
                                      selectedSlots: _allSelectedSlots,
                                      totalAmount: _totalAmount,
                                      selectedSlotIds: slotIds,
                                      selectedDate: dates,
                                      radioname: widget.radioname,
                                      radioid: widget.radioid,
                                    ),
                                  ),
                                  
                                );
                                   print("Selected Slot IDs: $slotIds");
        print("Selected Slot Dates: $dates");
                              }
                            : null,
                            
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          backgroundColor: _allSelectedSlots.isNotEmpty ? Colours.primarycolour : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: screenHeight * 0.022,
                            fontWeight: FontWeight.w600,
                            color: Colours.secondarycolour,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}