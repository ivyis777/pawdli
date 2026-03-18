
import 'package:flutter/material.dart';
import 'package:pawlli/core/storage_manager/colors.dart';
import 'package:pawlli/gen/fonts.gen.dart';


class SymptomWidget extends StatefulWidget {
  const SymptomWidget({super.key});

  @override
  State<SymptomWidget> createState() => _SymptomWidgetState();
}

class _SymptomWidgetState extends State<SymptomWidget> {
  final TextEditingController _otherProblemController = TextEditingController();
  final List<String> _symptoms = [
    'Fever', 'Cough', 'Headache', 'Nausea',
    'Sore Throat', 'Fatigue', 'Muscle Pain', 'Chills',
  ];
  Set<String> _selectedSymptoms = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Write Your Problem:",
          style: TextStyle(
        fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                   fontFamily: FontFamily.Cairo,
                    color: Colours.black,
          
          ),
        ),
        const SizedBox(height: 8.0),
        Card(
          color: Colours.secondarycolour,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _otherProblemController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter Your Problem',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: FontFamily.Cairo,
                  color: Colors.grey,
                ),
              ),
              maxLines: 4,
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          "Symptoms:",
          style: TextStyle(
              fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w500,
                   fontFamily: FontFamily.Cairo,
                    color: Colours.black,
        
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: _symptoms.map((symptom) {
            return SizedBox(
              width: (screenWidth - 48) / 2, 
              child: _buildSymptomButton(symptom),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomButton(String symptom) {
    final isSelected = _selectedSymptoms.contains(symptom);
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (isSelected) {
            _selectedSymptoms.remove(symptom);
          } else {
            _selectedSymptoms.add(symptom);
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Colours.primarycolour : Colours.secondarycolour,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        minimumSize: const Size(150, 50),
      ),
      child: Text(
        symptom,
        style: TextStyle(
          fontSize: 16,
          fontFamily: FontFamily.Cairo,
          color: isSelected ? Colours.secondarycolour : Colours.primarycolour,
        ),
      ),
    );
  }
}
