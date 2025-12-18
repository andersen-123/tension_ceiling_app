import 'dart:async';
import 'package:tension_ceiling_app/models/estimate.dart';

class AutoSaveService {
  Timer? _timer;
  Estimate? _currentEstimate;
  Future<void> Function()? _saveFunction;
  
  void startAutoSave(
    Estimate estimate,
    Future<void> Function() saveFunction, {
    Duration interval = const Duration(seconds: 30),
  }) {
    _currentEstimate = estimate;
    _saveFunction = saveFunction;
    
    _timer?.cancel();
    _timer = Timer.periodic(interval, (timer) async {
      if (_currentEstimate != null && _saveFunction != null) {
        await _saveFunction!();
        print('Автосохранение выполнено: ${DateTime.now()}');
      }
    });
  }
  
  void stopAutoSave() {
    _timer?.cancel();
    _timer = null;
    _currentEstimate = null;
    _saveFunction = null;
  }
  
  void pauseAutoSave() {
    _timer?.cancel();
  }
  
  void resumeAutoSave() {
    if (_currentEstimate != null && _saveFunction != null) {
      startAutoSave(_currentEstimate!, _saveFunction!);
    }
  }
  
  bool get isRunning => _timer != null && _timer!.isActive;
}
