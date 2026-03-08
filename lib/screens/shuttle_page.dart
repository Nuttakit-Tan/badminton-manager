import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

String formatDate(String date) {
  final parsed = DateTime.parse(date).toLocal();
  return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
}

class ShuttlePage extends StatefulWidget {
  const ShuttlePage({super.key});

  @override
  State<ShuttlePage> createState() => _ShuttlePageState();
}

class _ShuttlePageState extends State<ShuttlePage> {
  final supabase = Supabase.instance.client;
  final primaryColor = const Color(0xFFE8896B);

  List brands = [];
  String? selectedBrandId;
  List lots = [];

  @override
  void initState() {
    super.initState();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    final data = await supabase
        .from('shuttle_brands')
        .select()
        .eq('is_active', true)
        .order('created_at');

    setState(() {
      brands = data;
    });
  }

  Future<void> fetchLots(String brandId) async {
    final data = await supabase
        .from('shuttle_stock_lots')
        .select()
        .eq('brand_id', brandId)
        .order('created_at', ascending: false);

    setState(() {
      lots = data;
    });
  }

  Future<void> addBrand(String name, String model, int perTube) async {
    await supabase.from('shuttle_brands').insert({
      'name': name,
      'model': model,
      'shuttle_per_tube': perTube,
    });

    await fetchBrands();
  }

  Future<void> addLot(String brandId, int tubes, int perTube) async {
    int total = tubes * perTube;

    await supabase.from('shuttle_stock_lots').insert({
      'brand_id': brandId,
      'tubes': tubes,
      'shuttle_per_tube': perTube,
      'total_shuttle': total,
    });

    await fetchLots(brandId);
  }

  Future<void> deleteLot(String id) async {
    await supabase.from('shuttle_stock_lots').delete().eq('id', id);

    if (selectedBrandId != null) {
      await fetchLots(selectedBrandId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text("คลังลูกแบด")),
      floatingActionButton: FloatingActionButton(
        onPressed: showBrandForm,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Dropdown เลือกยี่ห้อ
          if (!(isLandscape && selectedBrandId != null))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "เลือกยี่ห้อ",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedBrandId != null)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor),
                                onPressed: () {
                                  final brand = brands.firstWhere(
                                    (b) => b['id'] == selectedBrandId,
                                  );

                                  showBrandForm(brand: brand);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: primaryColor.withOpacity(0.8),
                                ),
                                onPressed: confirmDeleteBrand,
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedBrandId,
                      hint: const Text("เลือกยี่ห้อ"),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: brands.map<DropdownMenuItem<String>>((brand) {
                        return DropdownMenuItem<String>(
                          value: brand['id'],
                          child: Text("${brand['name']} - ${brand['model']}"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedBrandId = value;
                        });

                        fetchLots(value);
                      },
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),

          /// ปุ่มเพิ่ม Lot
          if (selectedBrandId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 🔹 ปุ่มกลับ (เฉพาะแนวนอน)
                  if (isLandscape)
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor),
                            foregroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedBrandId = null;
                              lots = [];
                            });
                          },
                          icon: Icon(Icons.arrow_back, color: primaryColor),
                          label: const Text(
                            "กลับ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                  if (isLandscape) const SizedBox(width: 12),

                  // 🔹 ปุ่มเพิ่ม Lot
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => showLotForm(),
                        child: const Text(
                          "เพิ่ม Lot",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          /// รายการ Lot
          Expanded(
            child: ListView.builder(
              itemCount: lots.length,
              itemBuilder: (context, index) {
                final lot = lots[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      "Lot นี้มีจำนวนรวมทั้งหมด ${lot['total_shuttle']} ลูก",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text("มีทั้งหมด ${lot['tubes']} หลอด"),
                            Text(
                              "(1 หลอด = ${lot['shuttle_per_tube']} ลูก)",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "แค่ลูกแบด ${(lot['total_shuttle'] as int) - ((lot['tubes'] as int) * (lot['shuttle_per_tube'] as int))} ลูก",
                        ),
                        Text(
                          "รับ ณ ตั้งแต่วันที่ ${formatDate(lot['created_at'])}",
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: primaryColor),
                          onPressed: () => showLotForm(lot: lot),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: primaryColor.withOpacity(0.8),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("ยืนยันลบ"),
                                content: const Text(
                                  "ต้องการลบ Lot นี้หรือไม่?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("ยกเลิก"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                    ),
                                    onPressed: () {
                                      deleteLot(lot['id']);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("ลบ"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showBrandForm({Map<String, dynamic>? brand}) async {
    bool hasLot = false;

    if (brand != null) {
      final response = await supabase
          .from('shuttle_stock_lots')
          .select('id')
          .eq('brand_id', brand['id'])
          .limit(1);

      hasLot = response.isNotEmpty;
    }
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final nameCtrl = TextEditingController(text: brand?['name']);
    final modelCtrl = TextEditingController(text: brand?['model']);
    final perTubeCtrl = TextEditingController(
      text: brand?['shuttle_per_tube']?.toString() ?? "12",
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                width: 420,
                height: 350,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    /// 🔹 Scroll ส่วนฟอร์ม
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: AbsorbPointer(
                            absorbing: isSaving,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  brand == null ? "เพิ่มยี่ห้อ" : "แก้ไขยี่ห้อ",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                TextFormField(
                                  controller: nameCtrl,
                                  decoration: modernInput("ชื่อยี่ห้อ *"),
                                  validator: (v) => v == null || v.isEmpty
                                      ? "กรุณากรอกชื่อยี่ห้อ"
                                      : null,
                                ),

                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: modelCtrl,
                                  decoration: modernInput("รุ่น *"),
                                  validator: (v) => v == null || v.isEmpty
                                      ? "กรุณากรอกรุ่น"
                                      : null,
                                ),

                                const SizedBox(height: 12),

                                TextFormField(
                                  controller: perTubeCtrl,
                                  keyboardType: TextInputType.number,
                                  readOnly: hasLot,
                                  decoration: modernInput("ลูกต่อหลอด")
                                      .copyWith(
                                        suffixIcon: hasLot
                                            ? const Icon(
                                                Icons.lock,
                                                size: 18,
                                                color: Colors.grey,
                                              )
                                            : null,
                                      ),
                                ),

                                // 👇 ใส่ตรงนี้เลย
                                if (hasLot)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text(
                                      "ไม่สามารถแก้ไขได้ เนื่องจากมี Lot ในระบบแล้ว",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// 🔹 ปุ่มล่าง
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("ยกเลิก"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            onPressed: isSaving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate())
                                      return;

                                    setModalState(() => isSaving = true);

                                    try {
                                      final data = {
                                        'name': nameCtrl.text,
                                        'model': modelCtrl.text,
                                        'shuttle_per_tube':
                                            int.tryParse(perTubeCtrl.text) ??
                                            12,
                                      };

                                      if (brand == null) {
                                        await supabase
                                            .from('shuttle_brands')
                                            .insert(data);
                                      } else {
                                        await supabase
                                            .from('shuttle_brands')
                                            .update(data)
                                            .eq('id', brand['id']);
                                      }

                                      await fetchBrands();

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      setModalState(() => isSaving = false);
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
                                : Text(brand == null ? "เพิ่ม" : "บันทึก"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showLotForm({Map<String, dynamic>? lot}) {
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    // 1️⃣ หา brand ก่อน
    final brand = brands.firstWhere((b) => b['id'] == selectedBrandId);

    int perTube = brand['shuttle_per_tube'];

    // 2️⃣ ค่อยคำนวณค่าที่มีอยู่
    int existingTubes = lot?['tubes'] ?? 0;
    int existingTotal = lot?['total_shuttle'] ?? 0;

    int existingPieces = existingTotal - (existingTubes * perTube);

    // 3️⃣ แล้วค่อยสร้าง controller
    final tubeCtrl = TextEditingController(text: existingTubes.toString());

    final pieceCtrl = TextEditingController(text: existingPieces.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                width: 420,
                height: 300,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lot == null ? "เพิ่ม Lot" : "แก้ไข Lot",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: tubeCtrl,
                                keyboardType: TextInputType.number,
                                decoration: modernInput("จำนวนหลอด"),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "1 หลอด = $perTube ลูก",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 12),

                              TextFormField(
                                controller: pieceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: modernInput("จำนวนลูก"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("ยกเลิก"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            onPressed: () async {
                              int tubes = int.tryParse(tubeCtrl.text) ?? 0;
                              int pieces = int.tryParse(pieceCtrl.text) ?? 0;

                              int total = (tubes * perTube) + pieces;

                              if (lot == null) {
                                await supabase
                                    .from('shuttle_stock_lots')
                                    .insert({
                                      'brand_id': selectedBrandId,
                                      'tubes': tubes,
                                      'shuttle_per_tube': perTube,
                                      'total_shuttle': total,
                                    });
                              } else {
                                await supabase
                                    .from('shuttle_stock_lots')
                                    .update({
                                      'tubes': tubes,
                                      'shuttle_per_tube': perTube,
                                      'total_shuttle': total,
                                    })
                                    .eq('id', lot['id']);
                              }

                              await fetchLots(selectedBrandId!);

                              Navigator.pop(context);
                            },
                            child: Text(lot == null ? "เพิ่ม" : "บันทึก"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void confirmDeleteBrand() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ลบยี่ห้อ"),
        content: const Text("ต้องการลบลูกแบดยี่ห้อนี้หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              if (selectedBrandId == null) return;

              await supabase
                  .from('shuttle_brands')
                  .update({'is_active': false})
                  .eq('id', selectedBrandId!);

              Navigator.pop(context);

              selectedBrandId = null;
              lots = [];

              await fetchBrands();

              setState(() {});
            },
            child: const Text("ใช่ต้องการลบ"),
          ),
        ],
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
}
