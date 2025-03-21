import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/screens/user%20screens/home_screen.dart';
import 'package:montra/screens/user%20screens/income%20or%20expense/new_expense_screen.dart';
import 'package:montra/screens/user%20screens/income%20or%20expense/new_income_screen.dart';
import 'package:montra/screens/user%20screens/income%20or%20expense/new_transfer_screen.dart';
import 'package:montra/screens/user%20screens/transaction_screen.dart';
import 'package:montra/screens/user%20screens/budget_screen.dart';
import 'package:montra/screens/user%20screens/profile_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.user});

  final UserModel user;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isExpanded = false;
  late List<Widget> _pages;

  @override
  void initState() {
    // TODO: implement initState
    _pages = [
      HomeScreen(user: widget.user),
      const TransactionScreen(),
      const SizedBox(), // Placeholder for FAB action
      const BudgetScreen(),
      const ProfileScreen(),
    ];

    super.initState();
  }

  // final List<Widget> _pages = [
  //    HomeScreen(user: widget.user,),
  //   const TransactionScreen(),
  //   const SizedBox(), // Placeholder for FAB action
  //   const BudgetScreen(),
  //   const ProfileScreen(),
  // ];

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

          // Transfer button
          Positioned(
            bottom: 90.h,
            left: MediaQuery.of(context).size.width / 2 - 28.w,
            child: Visibility(
              visible: _isExpanded,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform: Matrix4.translationValues(
                  0,
                  _isExpanded ? -70.h : 0,
                  0,
                ),
                child: FloatingActionButton(
                  heroTag: "transfer",
                  onPressed: () {
                    print("Transfer pressed");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NewTransferScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.purple,
                  shape: const CircleBorder(),
                  child: Image.asset('assets/transaction_icon.png'),
                ),
              ),
            ),
          ),

          // Income button
          Positioned(
            bottom: 90.h,
            left: MediaQuery.of(context).size.width / 2 - 98.w,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform: Matrix4.translationValues(
                  0,
                  _isExpanded ? -20.h : 0,
                  0,
                ),
                child: FloatingActionButton(
                  heroTag: "income",
                  onPressed:
                      _isExpanded
                          ? () {
                            print("Income pressed");
                            // Navigate to Income Add Screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => NewIncomeScreen(),
                              ),
                            );
                          }
                          : null,
                  shape: const CircleBorder(),
                  child: Image.asset('assets/income.png'),
                ),
              ),
            ),
          ),

          // Expense button
          Positioned(
            bottom: 90.h,
            left: MediaQuery.of(context).size.width / 2 + 42.w,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform: Matrix4.translationValues(
                  0,
                  _isExpanded ? -20.h : 0,
                  0,
                ),
                child: FloatingActionButton(
                  heroTag: "expense",
                  onPressed:
                      _isExpanded
                          ? () {
                            print("Expense pressed");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => NewExpenseScreen(),
                              ),
                            );
                          }
                          : null,
                  shape: const CircleBorder(),
                  child: Image.asset('assets/expense.png'),
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
