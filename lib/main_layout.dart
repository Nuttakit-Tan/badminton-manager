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

  final Color primaryPeach = const Color(0xFFF28C6F);
  final Color secondaryBrown = const Color(0xFFC56A4D);
  final Color lightCream = const Color(0xFFF6EDE8);
  final Color softPeach = const Color(0xFFFDE5DD);

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
          drawer: isTablet ? null : buildDrawer(),
          body: Row(
            children: [
              if (isTablet) buildSidebar(),

              Expanded(
                child: Container(
                  color: const Color(0xFFF6EDE8), // cream background
                  child: Column(
                    children: [
                      // ===== Top Header =====
                      Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          titles[selectedIndex],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFC56A4D),
                          ),
                        ),
                      ),

                      // ===== Content Area =====
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: pages[selectedIndex],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
          colors: [Color(0xFFF29972), Color(0xFFC56A4D)],
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
          const SizedBox(height: 30),

          // ===== Logo Section ใหม่ =====
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Badminton Manager",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // เส้นคั่น
          const Divider(color: Colors.white24, thickness: 1),

          const SizedBox(height: 12),

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
        color: isSelected ? softPeach : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? secondaryBrown : Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? secondaryBrown : Colors.white,
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
        color: primaryPeach,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF28C6F), Color(0xFFC56A4D)],
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
        color: isSelected ? softPeach : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? secondaryBrown : Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? secondaryBrown : Colors.white,
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
