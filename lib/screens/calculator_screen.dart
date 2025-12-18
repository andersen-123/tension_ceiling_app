import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double _length = 0;
  double _width = 0;
  double _height = 2.5;
  double _area = 0;
  double _perimeter = 0;
  double _volume = 0;
  
  void _calculate() {
    setState(() {
      _area = _length * _width;
      _perimeter = 2 * (_length + _width);
      _volume = _area * _height;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Поля ввода
            _buildInputFields(),
            SizedBox(height: 20),
            
            // Кнопка расчета
            ElevatedButton(
              onPressed: _calculate,
              child: Text('Рассчитать'),
            ),
            SizedBox(height: 30),
            
            // Результаты
            _buildResults(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputFields() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Длина (м)',
                suffixText: 'м',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _length = double.tryParse(value) ?? 0;
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Ширина (м)',
                suffixText: 'м',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _width = double.tryParse(value) ?? 0;
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Высота (м)',
                suffixText: 'м',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _height = double.tryParse(value) ?? 2.5;
              },
              initialValue: '2.5',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResults() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text('Площадь'),
              trailing: Text('${_area.toStringAsFixed(2)} м²'),
            ),
            Divider(),
            ListTile(
              title: Text('Периметр'),
              trailing: Text('${_perimeter.toStringAsFixed(2)} м'),
            ),
            Divider(),
            ListTile(
              title: Text('Объем'),
              trailing: Text('${_volume.toStringAsFixed(2)} м³'),
            ),
          ],
        ),
      ),
    );
  }
}
