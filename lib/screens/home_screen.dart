import 'package:flutter/material.dart';
import 'package:tension_ceiling_app/screens/estimate_edit_screen.dart';
import 'estimate_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Список экранов для нижней навигации
  static final List<Widget> _screens = [
    const EstimateListScreen(), // Список смет (по умолчанию)
    Container(
      // Заглушка для экрана "Калькулятор"
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Калькулятор потолков',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text('В разработке...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сметы НОВАЯ ВЕРСИЯ 1.0.8'),
        centerTitle: true,
        actions: [
          // Кнопка создания новой сметы в AppBar
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EstimateEditScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Создать смету',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EstimateEditScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Сметы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
