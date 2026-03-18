import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/data/controller/pettherapyslotscontroller.dart';
import 'package:pawlli/data/model/therapyslot.dart';
import 'package:pawlli/gen/assests.gen.dart';
import 'package:pawlli/gen/fonts.gen.dart';
import 'package:pawlli/presentation/screens/pet%20therapy/book_therapyslot.dart';

class PetTherapySlot extends StatefulWidget {
  final int? petid;
  final DateTime selectedDate;

  const PetTherapySlot({super.key, required this.petid, required this.selectedDate});

  @override
  State<PetTherapySlot> createState() => _TimeSlotPageState();
}

class _TimeSlotPageState extends State<PetTherapySlot> {
  final TherapySlotController slotController = Get.put(TherapySlotController());

  final List<TherapySlot> _allSelectedSlots = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.petid != null) {
      // Use the date selected on the previous page
      final formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      final formattedDay = DateFormat('EEEE').format(widget.selectedDate);

      slotController.loadTherapySlots(
        therapyId: widget.petid!,
        day: formattedDay,
        date: formattedDate,
      );
    }
  }

  void _toggleSlotSelection(TherapySlot slot) {
    setState(() {
      final slotId = slot.slotId ?? 0;
      final amount = double.tryParse(slot.amount ?? '0') ?? 0.0;

      final alreadySelected = _allSelectedSlots.any((s) => s.slotId == slotId);

      if (alreadySelected) {
        _allSelectedSlots.removeWhere((s) => s.slotId == slotId);
        _totalAmount -= amount;
      } else {
        _allSelectedSlots.add(slot);
        _totalAmount += amount;
      }
    });
  }

  bool _isSlotSelected(TherapySlot slot) {
    return _allSelectedSlots.any((s) => s.slotId == slot.slotId);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

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
                  'Book Slots',
                  style: TextStyle(
                    fontSize: screenHeight * 0.035,
                    fontWeight: FontWeight.w600,
                    fontFamily: FontFamily.Cairo,
                    color: Colours.brownColour,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              // 👇 Show selected date below AppBar
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    'Selected Date: ${DateFormat.yMMMMd().format(widget.selectedDate)}',
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.w500,
                      fontFamily: FontFamily.Cairo,
                      color: Colours.primarycolour,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.02),

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
                                      '${slot.startTime}',
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
                              "No slots available",
                              style: TextStyle(
                                fontSize: screenHeight * 0.02,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        final groupedByDate = <String, List<TherapySlot>>{};
                        for (var slot in slotController.slotList) {
                          final date = slot.date ?? 'Unknown Date';
                          if (!groupedByDate.containsKey(date)) {
                            groupedByDate[date] = [];
                          }
                          groupedByDate[date]!.add(slot);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: groupedByDate.entries.map((entry) {
                            final date = entry.key;
                            final slots = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.022,
                                    fontWeight: FontWeight.bold,
                                    color: Colours.primarycolour,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: slots.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: screenWidth * 0.02,
                                    mainAxisSpacing: screenHeight * 0.010,
                                    childAspectRatio: 1.9,
                                  ),
                                  itemBuilder: (context, index) {
                                    final slot = slots[index];
                                    final isSelected = _isSlotSelected(slot);
                                    final isAvailable = slot.isAvailable ?? false;

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
                                                : (isAvailable
                                                    ? Colors.white
                                                    : Colors.grey.shade300),
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
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      }),

                      SizedBox(height: screenHeight * 0.02),

                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _allSelectedSlots.isNotEmpty
          ? () {
              final slotIds = _allSelectedSlots
                  .map((s) => s.slotId ?? 0)
                  .toList();
              final dates = _allSelectedSlots
                  .map((s) => s.date ?? '')
                  .toList();

              // ✅ Print selected slots and dates
              print('Selected Slots: $slotIds');
              print('Selected Dates: $dates');
              print('Total Amount: $_totalAmount');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => pettherapyslotPage(
                    selectedSlots: _allSelectedSlots,
                    totalAmount: _totalAmount,
                    selectedSlotIds: slotIds,
                    selectedDate: dates,
                    petid: widget.petid,
                  ),
                ),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        backgroundColor: _allSelectedSlots.isNotEmpty
            ? Colours.primarycolour
            : Colors.grey,
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

                        ),
                      ),

                      SizedBox(height: screenHeight * 0.15),
                    ],
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
