import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

int calculateAge(DateTime birthDate) {
  final today = DateTime.now();
  int age = today.year - birthDate.year;

  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age;
}

class _MembersPageState extends State<MembersPage> {
  final supabase = Supabase.instance.client;

  List members = [];
  List skillLevels = [];

  bool isLoading = true;
  int? selectedSkillId;

  int limit = 10;
  int offset = 0;
  bool isFetchingMore = false;
  bool hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMembers();
    fetchSkillLevels();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !isFetchingMore &&
          hasMore) {
        fetchMoreMembers();
      }
    });
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
        birth_date,
        phone,
        line_id,
        skill_level_id,
        skill_levels (
          code
        )
      ''')
        .eq('owner_id', userId)
        .order('created_at')
        .range(offset, offset + limit - 1);

    setState(() {
      members = data;
      hasMore = data.length == limit;
      offset = data.length;
      isLoading = false;
    });
  }

  Future<void> fetchMoreMembers() async {
    if (!hasMore) return;

    setState(() => isFetchingMore = true);

    final userId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('members')
        .select('''
        id,
        full_name,
        nickname,
        birth_date,
        phone,
        line_id,
        skill_level_id,
        skill_levels (
          code
        )
      ''')
        .eq('owner_id', userId)
        .order('created_at')
        .range(offset, offset + limit - 1);

    setState(() {
      members.addAll(data);
      offset += data.length;
      hasMore = data.length == limit;
      isFetchingMore = false;
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

  void showMemberForm({Map<String, dynamic>? member}) {
    final formKey = GlobalKey<FormState>();

    bool isSaving = false;

    final nameCtrl = TextEditingController(text: member?['full_name']);
    final nickCtrl = TextEditingController(text: member?['nickname']);
    final phoneCtrl = TextEditingController(text: member?['phone']);
    final lineCtrl = TextEditingController(text: member?['line_id']);

    DateTime? selectedDate = member?['birth_date'] != null
        ? DateTime.parse(member!['birth_date'])
        : null;

    selectedSkillId = member?['skill_level_id'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 420, // 👈 กำหนดขนาดตรงนี้
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: AbsorbPointer(
                      absorbing: isSaving,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ข้อมูลสมาชิก",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ชื่อจริง
                          TextFormField(
                            controller: nameCtrl,
                            decoration: modernInput("ชื่อจริง"),
                          ),

                          const SizedBox(height: 12),

                          // ชื่อเล่น
                          TextFormField(
                            controller: nickCtrl,
                            decoration: modernInput("ชื่อเล่น *"),
                            validator: (v) => v == null || v.isEmpty
                                ? "กรุณากรอกชื่อเล่น"
                                : null,
                          ),

                          const SizedBox(height: 12),

                          // วันเกิด
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                                initialEntryMode: DatePickerEntryMode.input,
                                helpText: 'เลือกวันเกิด',
                                fieldHintText: 'วว/ดด/ปปปป',
                                errorFormatText: 'ใส่เลขวันไม่ถูกต้อง',
                                errorInvalidText: 'วันที่ไม่ถูกต้อง',
                              );

                              if (picked != null) {
                                setModalState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: modernInput("วันเกิด"),
                              child: Text(
                                selectedDate == null
                                    ? "-"
                                    : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                          "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                          "${selectedDate!.year}",
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: phoneCtrl,
                            decoration: modernInput("เบอร์โทร"),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: lineCtrl,
                            decoration: modernInput("Line ID"),
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<int>(
                            decoration: modernInput("ระดับมือ *"),
                            value: selectedSkillId,
                            items: skillLevels.map<DropdownMenuItem<int>>((
                              level,
                            ) {
                              return DropdownMenuItem<int>(
                                value: level['id'],
                                child: Text(level['code']),
                              );
                            }).toList(),
                            validator: (v) =>
                                v == null ? "กรุณาเลือกระดับมือ" : null,
                            onChanged: (v) {
                              selectedSkillId = v;
                            },
                          ),

                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("ยกเลิก"),
                              ),
                              ElevatedButton(
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate())
                                          return;

                                        setModalState(() => isSaving = true);

                                        try {
                                          final userId =
                                              supabase.auth.currentUser!.id;

                                          final data = {
                                            'owner_id': userId,
                                            'full_name': nameCtrl.text,
                                            'nickname': nickCtrl.text,
                                            'birth_date': selectedDate
                                                ?.toIso8601String(),
                                            'phone': phoneCtrl.text,
                                            'line_id': lineCtrl.text,
                                            'skill_level_id': selectedSkillId,
                                          };

                                          if (member == null) {
                                            await supabase
                                                .from('members')
                                                .insert(data);
                                          } else {
                                            await supabase
                                                .from('members')
                                                .update(data)
                                                .eq('id', member['id']);
                                          }

                                          await fetchMembers();

                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        } catch (e) {
                                          setModalState(() => isSaving = false);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "เกิดข้อผิดพลาด: $e",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(member == null ? "เพิ่ม" : "บันทึก"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
              controller: _scrollController,
              itemCount: members.length + (isFetchingMore ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == members.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final m = members[index];

                // 👇 ต้องประกาศก่อน
                final birthDate = m['birth_date'] != null
                    ? DateTime.parse(m['birth_date'])
                    : null;

                final birthText = birthDate != null
                    ? "${birthDate.day.toString().padLeft(2, '0')}/"
                          "${birthDate.month.toString().padLeft(2, '0')}/"
                          "${birthDate.year}"
                    : '-';

                final age = birthDate != null ? calculateAge(birthDate) : null;

                final skill = m['skill_levels'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              m['nickname'] ?? '-',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showMemberForm(member: m);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: const Text("ยืนยันการลบ"),
                                          content: Text(
                                            "คุณต้องการลบสมาชิก \"${m['nickname']}\" ใช่หรือไม่?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text("ยกเลิก"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text("ลบ"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    // ถ้าผู้ใช้กดยืนยัน
                                    if (confirm == true) {
                                      await supabase
                                          .from('members')
                                          .delete()
                                          .eq('id', m['id']);

                                      await fetchMembers();

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "ลบสมาชิกเรียบร้อยแล้ว",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Divider(),

                        // 🔹 2 Column Layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Column ซ้าย
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow("ชื่อจริง", m['full_name']),
                                  _infoRow("วันเกิด", birthText),
                                  _infoRow(
                                    "อายุ",
                                    age != null ? "$age ปี" : "-",
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 30),

                            // Column ขวา
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow("โทรศัพท์", m['phone']),
                                  _infoRow("Line ID", m['line_id']),
                                  _infoRow("ระดับมือ", skill?['code']),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showMemberForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  InputDecoration modernInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$label :",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }
}
