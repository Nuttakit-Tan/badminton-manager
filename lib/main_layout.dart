import 'package:flutter/material.dart';
import 'screens/members_page.dart';
import 'screens/match_page.dart';
import 'screens/shuttle_page.dart';
import 'screens/history_page.dart';
import 'screens/payment_history_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  bool isSidebarExpanded = false;

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
              if (isTablet)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: isSidebarExpanded ? 220 : 70,
                  child: buildSidebar(),
                ),

              Expanded(
                child: Container(
                  color: const Color(0xFFF6EDE8), // cream background
                  child: SafeArea(
                    child: Column(
                      children: [
                        // ===== Top Header =====
                        Builder(
                          builder: (context) => Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                if (!isTablet)
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  titles[selectedIndex.clamp(
                                    0,
                                    titles.length - 1,
                                  )],
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC56A4D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ===== Content Area =====
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 1,
                            ),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF29972), Color(0xFFC56A4D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            /// ===== ปุ่มขยาย / หด =====
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isSidebarExpanded = !isSidebarExpanded;
                  });
                },
              ),
            ),

            if (isSidebarExpanded)
              Transform.translate(
                offset: const Offset(0, -30), // 👈 ปรับเลขตรงนี้
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Badminton Manager",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 0),
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildRailItem(Icons.people, "รายชื่อ", 0),
                    buildRailItem(Icons.sports_tennis, "จัดก๊วน", 1),
                    buildRailItem(Icons.add_box, "ลูกแบด", 2),
                    buildRailItem(Icons.history, "ประวัติ", 3),
                    buildRailItem(Icons.payment, "ชำระเงิน", 4),
                    buildRailItem(Icons.logout, "ออกจากระบบ", 99),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRailItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () async {
        if (index == 99) {
          await Supabase.instance.client.auth.signOut();

          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
          return;
        }

        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: isSidebarExpanded ? 16 : 0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isSidebarExpanded
            ? Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    // 👈 สำคัญมาก
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Center(child: Icon(icon, color: Colors.white, size: 26)),
      ),
    );
  }

  // ================= MOBILE DRAWER =================

  Drawer buildDrawer() {
    return Drawer(
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: primaryPeach,
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Badminton Manager",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          buildDrawerItem(Icons.people, "สร้างรายชื่อ", 0),
          buildDrawerItem(Icons.sports_tennis, "จัดก๊วน", 1),
          buildDrawerItem(Icons.add_box, "เพิ่มรายการลูกแบด", 2),
          buildDrawerItem(Icons.history, "ประวัติการจัดก๊วน", 3),
          buildDrawerItem(Icons.payment, "ประวัติการชำระเงิน", 4),
          buildDrawerItem(Icons.logout, "ออกจากระบบ", 99),
        ],
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
        onTap: () async {
          if (index == 99) {
            await Supabase.instance.client.auth.signOut();

            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
            return; // 🔥 สำคัญมาก
          }

          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
