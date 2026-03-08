import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShuttlePage extends StatefulWidget {
  const ShuttlePage({super.key});

  @override
  State<ShuttlePage> createState() => _ShuttlePageState();
}

class _ShuttlePageState extends State<ShuttlePage> {
  final supabase = Supabase.instance.client;

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
    return Scaffold(
      appBar: AppBar(title: const Text("คลังลูกแบด")),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddBrandDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Dropdown เลือกยี่ห้อ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField(
              value: selectedBrandId,
              hint: const Text("เลือกยี่ห้อ"),
              items: brands.map<DropdownMenuItem>((brand) {
                return DropdownMenuItem(
                  value: brand['id'],
                  child: Text("${brand['name']} - ${brand['model']}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBrandId = value;
                });
                fetchLots(value);
              },
            ),
          ),

          const SizedBox(height: 10),

          /// ปุ่มเพิ่ม Lot
          if (selectedBrandId != null)
            ElevatedButton(
              onPressed: showAddLotDialog,
              child: const Text("เพิ่ม Lot"),
            ),

          const SizedBox(height: 10),

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
                      "เพิ่ม ${lot['tubes']} หลอด (${lot['total_shuttle']} ลูก)",
                    ),
                    subtitle: Text("วันที่: ${lot['created_at']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("ยืนยันลบ"),
                            content: const Text("ต้องการลบ Lot นี้หรือไม่?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("ยกเลิก"),
                              ),
                              ElevatedButton(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showAddBrandDialog() {
    final nameController = TextEditingController();
    final modelController = TextEditingController();
    final perTubeController = TextEditingController(text: "12");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เพิ่มยี่ห้อ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "ชื่อยี่ห้อ"),
            ),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: "รุ่น"),
            ),
            TextField(
              controller: perTubeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "ลูกต่อหลอด"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await addBrand(
                nameController.text,
                modelController.text,
                int.parse(perTubeController.text),
              );
              Navigator.pop(context);
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  void showAddLotDialog() {
    final tubeController = TextEditingController();

    final brand = brands.firstWhere((b) => b['id'] == selectedBrandId);

    int perTube = brand['shuttle_per_tube'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เพิ่ม Lot"),
        content: TextField(
          controller: tubeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "จำนวนหลอด"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await addLot(
                selectedBrandId!,
                int.parse(tubeController.text),
                perTube,
              );
              Navigator.pop(context);
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }
}
