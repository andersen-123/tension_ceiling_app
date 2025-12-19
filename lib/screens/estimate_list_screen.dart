import 'package:flutter/material.dart';
import 'package:tension_ceiling_app/database/database_helper.dart';
import 'package:tension_ceiling_app/models/estimate.dart';
import 'estimate_edit_screen.dart';

class EstimateListScreen extends StatefulWidget {
  const EstimateListScreen({super.key});

  @override
  State<EstimateListScreen> createState() => _EstimateListScreenState();
}

class _EstimateListScreenState extends State<EstimateListScreen> {
  List<Estimate> _estimates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEstimates();
  }

  // ЗАГРУЗИТЬ все сметы из базы данных
  Future<void> _loadEstimates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final db = await DatabaseHelper.instance.database;
      
      // Выполняем запрос: получаем ВСЕ записи из таблицы 'estimates'
      // и сортируем по дате создания (новые сверху)
      final List<Map<String, dynamic>> maps = await db.query(
        'estimates',
        orderBy: 'created_at DESC',
      );

      // Преобразуем данные из БД в список объектов Estimate
      setState(() {
        _estimates = List.generate(maps.length, (index) {
          return Estimate.fromMap(maps[index]);
        });
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: $error';
        _isLoading = false;
      });
    }
  }

  // УДАЛИТЬ смету
  Future<void> _deleteEstimate(int id, String title) async {
    // Показать диалог подтверждения
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить смету?'),
        content: Text('Вы уверены, что хотите удалить "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final db = await DatabaseHelper.instance.database;
        await db.delete(
          'estimates',
          where: 'id = ?',
          whereArgs: [id],
        );

        // Убираем удаленную смету из списка
        setState(() {
          _estimates.removeWhere((estimate) => estimate.id == id);
        });

        // Показываем уведомление
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Смета "$title" удалена'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ПЕРЕЙТИ к редактированию сметы
  void _navigateToEdit(Estimate estimate) async {
    // Переходим на экран редактирования, передаем выбранную смету
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstimateEditScreen(existingEstimate: estimate),
      ),
    );

    // Если вернулись с флагом успешного сохранения — обновляем список
    if (result == true && mounted) {
      await _loadEstimates();
    }
  }

  // ПОСТРОИТЬ интерфейс
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Все сметы'),
        centerTitle: true,
        actions: [
          // Кнопка обновления списка
          IconButton(
            onPressed: _loadEstimates,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить список',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Создаем новую смету
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EstimateEditScreen(),
            ),
          ).then((result) {
            // После возвращения обновляем список
            if (result == true && mounted) {
              _loadEstimates();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ОСНОВНОЙ контент экрана
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEstimates,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_estimates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Смет пока нет',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const Text(
              'Нажмите "+" чтобы создать первую',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EstimateEditScreen(),
                  ),
                ).then((result) {
                  if (result == true && mounted) {
                    _loadEstimates();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Создать смету'),
            ),
          ],
        ),
      );
    }

    // ОТОБРАЖЕНИЕ списка смет
    return RefreshIndicator(
      onRefresh: _loadEstimates,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _estimates.length,
        itemBuilder: (context, index) {
          final estimate = _estimates[index];
          return _buildEstimateCard(estimate);
        },
      ),
    );
  }

  // КАРТОЧКА одной сметы
  Widget _buildEstimateCard(Estimate estimate) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEdit(estimate),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка удаления
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      estimate.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteEstimate(estimate.id!, estimate.title),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Удалить',
                  ),
                ],
              ),

              // Описание (если есть)
              if (estimate.description != null && estimate.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  estimate.description!,
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Итоговая сумма и дата
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Сумма
                  Text(
                    '${estimate.totalPrice.toStringAsFixed(2)} ₽',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  // Дата создания
                  Text(
                    _formatDate(estimate.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              // Подсказка
              const SizedBox(height: 8),
              const Text(
                'Нажмите для редактирования',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ФОРМАТИРОВАНИЕ даты
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Сегодня
    if (difference.inDays == 0) {
      return 'Сегодня, ${_formatTime(date)}';
    }
    // Вчера
    if (difference.inDays == 1) {
      return 'Вчера, ${_formatTime(date)}';
    }
    // На этой неделе
    if (difference.inDays < 7) {
      return '${difference.inDays} дня назад';
    }
    // Более недели назад
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
