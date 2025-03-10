import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/screens/user%20screens/home_screen.dart';
import 'package:montra/screens/user%20screens/transaction_screen.dart';
import 'package:montra/screens/user%20screens/budget_screen.dart';
import 'package:montra/screens/user%20screens/profile_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isExpanded = false;

  final List<Widget> _pages = [
    const HomeScreen(),
    const TransactionScreen(),
    const SizedBox(), // Placeholder for FAB action
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index != 2) {
      setState(() {
        _selectedIndex = index;
        _isExpanded = false; // Close floating button menu when switching tabs
      });
    }
  }

  void _toggleFabMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_isExpanded)
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Container(
                height: 160.h,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Transfer button (top)
                      Transform.translate(
                        offset: Offset(0, -70.h),
                        child: FloatingActionButton(
                          heroTag: "transfer",
                          onPressed: () {
                            // Navigate to Transfer Screen
                          },
                          shape: const CircleBorder(),
                          child: Image.asset('assets/transaction_icon.png'),
                        ),
                      ),
                      // Income button (left)
                      Transform.translate(
                        offset: Offset(-70.w, -20.h),
                        child: FloatingActionButton(
                          heroTag: "income",
                          onPressed: () {
                            // Navigate to Income Add Screen
                          },
                          shape: const CircleBorder(),
                          child: Image.asset('assets/income.png'),
                        ),
                      ),
                      // Expense button (right)
                      Transform.translate(
                        offset: Offset(70.w, -20.h),
                        child: FloatingActionButton(
                          heroTag: "expense",
                          onPressed: () {
                            // Navigate to Expense Add Screen
                          },
                          shape: const CircleBorder(),
                          child: Image.asset('assets/expense.png'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: "Transaction",
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: _toggleFabMenu,
              child: CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.purple,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.add,
                  color: Colors.white,
                  size: 32.r,
                ),
              ),
            ),
            label: "",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Budget",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
