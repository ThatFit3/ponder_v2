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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
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
        selectedTime!.minute
            .toString()
            .padLeft(2, '0'); // 24-hour formatted string

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

      Navigator.pop(context, true); // Return true to indicate update
    } catch (e) {
      print('Error saving time: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add time.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Scheduled Time"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: pickTime,
              icon: const Icon(Icons.access_time),
              label: const Text("Pick Time (24h)"),
            ),
            const SizedBox(height: 20),
            if (selectedTime != null)
              Text(
                "Selected: ${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: selectedTime == null ? null : saveTime,
              child: const Text("Save Time"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
