import 'package:flutter/material.dart';
import 'package:tension_ceiling_app/screens/estimate_list_screen.dart';
import 'package:tension_ceiling_app/screens/template_screen.dart';
import 'package:tension_ceiling_app/screens/calculator_screen.dart';
import 'package:tension_ceiling_app/screens/history_screen.dart';
import 'package:tension_ceiling_app/screens/import_screen.dart';
import 'package:tension_ceiling_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    EstimateListScreen(),
    TemplateScreen(),
    CalculatorScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];
  
  final List<String> _appBarTitles = [
    'Мои сметы',
    'Шаблоны',
    'Калькулятор',
    'История',
    'Настройки',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_currentIndex]),
        actions: _currentIndex == 0 ? [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImportScreen(),
                ),
              );
            },
          ),
        ] : null,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Сметы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Шаблоны',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EstimateEditScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ) : null,
    );
  }
}
