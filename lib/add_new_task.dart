import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_tutorial/utils.dart';



class AddNewTask extends StatefulWidget {
  final Map<String, dynamic>? taskData;
  final String? taskId;

  const AddNewTask({
    super.key,
    this.taskData,
    this.taskId,
  });

  @override
  State<AddNewTask> createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Color _selectedColor = Colors.blue;
  File? file;

  @override
  void initState() {
    super.initState();
    if (widget.taskData != null) {
      titleController.text = widget.taskData!['title'];
      descriptionController.text = widget.taskData!['description'];
      selectedDate = (widget.taskData!['date'] as Timestamp).toDate();
      _selectedColor = hexToColor(widget.taskData!['color']);
    }
  }

 
  

  String rgbToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> uploadTasktoDb() async {
    try {
      final taskData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'date': selectedDate,
        'postedAt': FieldValue.serverTimestamp(),
        'color': rgbToHex(_selectedColor),
        'creator': FirebaseAuth.instance.currentUser?.uid,
      };

      if (widget.taskId != null) {
        await FirebaseFirestore.instance
            .collection("tasks")
            .doc(widget.taskId)
            .update(taskData);
      } else {
        final id = Uuid().v4();
        await FirebaseFirestore.instance
            .collection("tasks")
            .doc(id)
            .set(taskData);
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        actions: [
          GestureDetector(
            onTap: () async {
              final selDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (selDate != null) {
                setState(() {
                  selectedDate = selDate;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.calendar_today,
                color: Colors.grey[700],
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
            
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ColorPicker(
                pickersEnabled: const {ColorPickerType.wheel: true},
                color: Colors.blue,
                onColorChanged: (Color color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                heading: const Text('Select color'),
                subheading: const Text('Select a different shade'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await uploadTasktoDb();
                },
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
