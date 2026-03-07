import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final supabase = Supabase.instance.client;

  List members = [];
  List skillLevels = [];

  bool isLoading = true;
  int? selectedSkillId;

  @override
  void initState() {
    super.initState();
    fetchMembers();
    fetchSkillLevels(); // โหลดระดับมือ
  }

  // =========================
  // FETCH MEMBERS (JOIN skill_levels)
  // =========================
  Future<void> fetchMembers() async {
    final userId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('members')
        .select('''
          id,
          full_name,
          nickname,
          phone,
          skill_levels (
            id,
            code,
            min_level,
            max_level
          )
        ''')
        .eq('owner_id', userId)
        .order('created_at');

    setState(() {
      members = data;
      isLoading = false;
    });
  }

  // =========================
  // FETCH SKILL LEVELS
  // =========================
  Future<void> fetchSkillLevels() async {
    final data = await supabase.from('skill_levels').select().order('ranking');

    setState(() {
      skillLevels = data;
    });
  }

  // =========================
  // ADD MEMBER
  // =========================
  Future<void> addMember(String name, String nickname, String phone) async {
    final userId = supabase.auth.currentUser!.id;

    if (selectedSkillId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเลือกระดับฝีมือ")));
      return;
    }

    await supabase.from('members').insert({
      'owner_id': userId,
      'full_name': name,
      'nickname': nickname,
      'phone': phone,
      'skill_level_id': selectedSkillId,
    });

    await fetchMembers();
  }

  // =========================
  // DIALOG
  // =========================
  void showAddDialog() {
    final nameCtrl = TextEditingController();
    final nickCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    selectedSkillId = null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เพิ่มสมาชิก"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "ชื่อจริง"),
              ),
              TextField(
                controller: nickCtrl,
                decoration: const InputDecoration(labelText: "ชื่อเล่น"),
              ),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: "เบอร์โทร"),
              ),
              const SizedBox(height: 12),

              // 🔥 Dropdown ดึงจาก skill_levels
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "ระดับฝีมือ"),
                value: selectedSkillId,
                items: skillLevels.map<DropdownMenuItem<int>>((level) {
                  return DropdownMenuItem<int>(
                    value: level['id'],
                    child: Text(level['code']), // 👈 แสดงแค่ code
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSkillId = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            onPressed: () async {
              await addMember(nameCtrl.text, nickCtrl.text, phoneCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("รายชื่อสมาชิกของฉัน")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(child: Text("ยังไม่มีสมาชิก"))
          : ListView.builder(
              itemCount: members.length,
              itemBuilder: (_, index) {
                final m = members[index];
                final skill = m['skill_levels'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(m['full_name'] ?? '-'),
                    subtitle: Text(
                      "ชื่อเล่น: ${m['nickname'] ?? '-'}\n"
                      "โทร: ${m['phone'] ?? '-'}\n"
                      "ระดับ: ${skill?['code']} "
                      "(${skill?['min_level']}-${skill?['max_level']})",
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
