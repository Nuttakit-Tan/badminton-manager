import 'package:flutter/material.dart';
import 'screens/members_page.dart';
import 'screens/match_page.dart';
import 'screens/shuttle_page.dart';
import 'screens/history_page.dart';
import 'screens/payment_history_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  final Color primaryGreen = const Color(0xFF14532D);
  final Color activeGreen = const Color(0xFF22C55E);
  final Color lightGreen = const Color(0xFFDCFCE7);

  final List<Widget> pages = const [
    MembersPage(),
    MatchPage(),
    ShuttlePage(),
    HistoryPage(),
    PaymentHistoryPage(),
  ];

  final List<String> titles = const [
    "สร้างรายชื่อ",
    "จัดก๊วน",
    "เพิ่มรายการลูกแบด",
    "ประวัติการจัดก๊วน",
    "ประวัติการชำระเงิน",
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 800;

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[selectedIndex]),
            backgroundColor: primaryGreen,
          ),
          drawer: isTablet ? null : buildDrawer(),
          body: Row(
            children: [
              if (isTablet) buildSidebar(),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: pages[selectedIndex],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= SIDEBAR TABLET =================

  Widget buildSidebar() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF166534)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            "🏸 Badminton",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          buildRailItem(Icons.people, "รายชื่อ", 0),
          buildRailItem(Icons.sports_tennis, "จัดก๊วน", 1),
          buildRailItem(Icons.add_box, "ลูกแบด", 2),
          buildRailItem(Icons.history, "ประวัติ", 3),
          buildRailItem(Icons.payment, "ชำระเงิน", 4),
        ],
      ),
    );
  }

  Widget buildRailItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? lightGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? primaryGreen : Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryGreen : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }

  // ================= MOBILE DRAWER =================

  Drawer buildDrawer() {
    return Drawer(
      child: Container(
        color: primaryGreen,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                ),
              ),
              child: Text(
                "🏸 Badminton Manager",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildDrawerItem(Icons.people, "สร้างรายชื่อ", 0),
            buildDrawerItem(Icons.sports_tennis, "จัดก๊วน", 1),
            buildDrawerItem(Icons.add_box, "เพิ่มรายการลูกแบด", 2),
            buildDrawerItem(Icons.history, "ประวัติการจัดก๊วน", 3),
            buildDrawerItem(Icons.payment, "ประวัติการชำระเงิน", 4),
          ],
        ),
      ),
    );
  }

  Widget buildDrawerItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? lightGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? primaryGreen : Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryGreen : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}
