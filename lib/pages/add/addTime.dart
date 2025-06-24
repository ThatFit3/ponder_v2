import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTime extends StatefulWidget {
  final String sensorId;

  const AddTime({Key? key, required this.sensorId}) : super(key: key);

  @override
  State<AddTime> createState() => _AddTimeState();
}

class _AddTimeState extends State<AddTime> {
  TimeOfDay? selectedTime;

  Future<void> pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      // 12-hour format input by default
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> saveTime() async {
    if (selectedTime == null) return;

    final String formattedTime = selectedTime!.hour.toString().padLeft(2, '0') +
        ":" +
        selectedTime!.minute.toString().padLeft(2, '0');

    try {
      await FirebaseFirestore.instance
          .collection('sensors')
          .doc(widget.sensorId)
          .update({
        'times': FieldValue.arrayUnion([formattedTime])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Time $formattedTime added successfully."),
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving time: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add time.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? displayTime = selectedTime == null
        ? null
        : selectedTime!.format(context); // 12-hour format

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Scheduled Time"),
        elevation: 4,
        shadowColor: Colors.black45,
        backgroundColor: const Color.fromARGB(255, 166, 227, 233),
      ),
      backgroundColor: const Color(0xFFF2F4F8),
      body: Center(
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select a Time",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: pickTime,
                  icon: const Icon(Icons.access_time),
                  label: const Text("Pick Time (12h)"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 131, 184, 189),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                ),
                const SizedBox(height: 25),
                if (displayTime != null)
                  Text(
                    "Selected: $displayTime",
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: selectedTime == null ? null : saveTime,
                  child: const Text("Save Time"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        selectedTime == null ? Colors.grey : Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
