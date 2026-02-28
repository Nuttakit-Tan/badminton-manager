import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final nameController = TextEditingController();
  final GroupService service = GroupService();

  String paymentType = "shuttle";
  double courtPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("สร้างก๊วนใหม่")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "ชื่อก๊วน"),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField(
              initialValue: paymentType,
              items: const [
                DropdownMenuItem(value: "shuttle", child: Text("จ่ายตามลูก")),
                DropdownMenuItem(value: "buffet", child: Text("บุฟเฟ่")),
                DropdownMenuItem(value: "share", child: Text("หารเท่ากัน")),
              ],
              onChanged: (value) {
                setState(() {
                  paymentType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            if (paymentType != "buffet")
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "ค่าคอร์ด"),
                onChanged: (value) {
                  courtPrice = double.tryParse(value) ?? 0;
                },
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final group = GroupModel(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  paymentType: paymentType,
                  courtPrice: courtPrice,
                  startTime: DateTime.now(),
                  endTime: DateTime.now().add(const Duration(hours: 3)),
                );

                await service.addGroup(group);
                Navigator.pop(context);
              },
              child: const Text("บันทึก"),
            ),
          ],
        ),
      ),
    );
  }
}
