import 'dart:async';

import 'package:flutter/material.dart';
import '../models/device_data.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';

class DeviceProvider with ChangeNotifier {
  DeviceData _currentData = DeviceData();
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _error = '';
  StreamSubscription? _batterySubscription;
  
  final DataService _dataService = DataService();
  final StorageService _storageService = StorageService();
  
  DeviceData get currentData => _currentData;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String get error => _error;
  
  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }
  
  // Initialize data with REAL sensor data
  Future<void> initializeData() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get all device data from platform channels
      final allData = await _dataService.getAllDeviceData();
      final cellularData = await _dataService.getCellularInfo();
      
 // In lib/providers/device_provider.dart, update initializeData():
_currentData = DeviceData(
  batteryLevel: allData['batteryLevel'] ?? 0,
  batteryTemperature: (allData['batteryTemperature'] ?? 0.0).toDouble(),
  batteryHealth: _getBatteryHealthString(allData['batteryHealth'] ?? 0),
  deviceModel: allData['deviceModel'] ?? 'Unknown',
  androidVersion: allData['androidVersion'] ?? 'Unknown',
  deviceName: allData['deviceName'] ?? 'Unknown',
  wifiSSID: allData['wifiSSID'] ?? 'Not Connected',
  wifiRSSI: allData['wifiRSSI'] ?? 0,
  localIP: allData['localIP'] ?? '0.0.0.0',
  carrierName: cellularData['carrierName'] ?? 'Unknown',
  cellularSignal: cellularData['cellularSignal'] ?? 0,
  simState: _getSimStateString(cellularData['simState'] ?? 0),
  stepCount: allData['stepCount'] ?? 0,
  stepDetectorCount: allData['stepDetectorCount'] ?? 0,       // ADD THIS
  hasStepCounter: allData['hasStepCounter'] ?? false,         // ADD THIS
  hasStepDetector: allData['hasStepDetector'] ?? false,       // ADD THIS
  detectedActivity: allData['detectedActivity'] ?? 'Still',
  timestamp: DateTime.now(),
);
      
      // Start listening for battery updates
      _startBatteryUpdates();
      
      // Save to storage
      await _storageService.saveLastData(_currentData);
      
      _error = '';
    } catch (e) {
      _error = 'Failed to load device data: $e';
      print('Error in initializeData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Refresh data
  Future<void> refreshData() async {
    try {
      _isRefreshing = true;
      notifyListeners();
      
      // Get fresh data from platform channels
      final allData = await _dataService.getAllDeviceData();
      final cellularData = await _dataService.getCellularInfo();
      
      _currentData = DeviceData(
        batteryLevel: allData['batteryLevel'] ?? 0,
        batteryTemperature: (allData['batteryTemperature'] ?? 0.0).toDouble(),
        batteryHealth: _getBatteryHealthString(allData['batteryHealth'] ?? 0),
        deviceModel: allData['deviceModel'] ?? 'Unknown',
        androidVersion: allData['androidVersion'] ?? 'Unknown',
        deviceName: allData['deviceName'] ?? 'Unknown',
        wifiSSID: allData['wifiSSID'] ?? 'Not Connected',
        wifiRSSI: allData['wifiRSSI'] ?? 0,
        localIP: allData['localIP'] ?? '0.0.0.0',
        carrierName: cellularData['carrierName'] ?? 'Unknown',
        cellularSignal: cellularData['cellularSignal'] ?? 0,
        simState: _getSimStateString(cellularData['simState'] ?? 0),
        stepCount: allData['stepCount'] ?? 0,
        detectedActivity: allData['detectedActivity'] ?? 'Still',
        timestamp: DateTime.now(),
      );
      
      _error = '';
    } catch (e) {
      _error = 'Failed to refresh: $e';
      print('Error in refreshData: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
  
  // Start listening for battery updates
  void _startBatteryUpdates() {
    _batterySubscription = _dataService.getBatteryStream().listen((batteryData) {
      // Update battery info in real-time
      _currentData = _currentData.copyWith(
        batteryLevel: batteryData['level'] ?? _currentData.batteryLevel,
        batteryTemperature: (batteryData['temperature'] ?? _currentData.batteryTemperature).toDouble(),
        batteryHealth: _getBatteryHealthString(batteryData['health'] ?? 0),
      );
      notifyListeners();
    }, onError: (error) {
      print('Battery stream error: $error');
    });
  }
  
  // Helper: Convert battery health code to string
  String _getBatteryHealthString(int healthCode) {
    switch (healthCode) {
      case 2: return 'Good';
      case 3: return 'Overheat';
      case 4: return 'Dead';
      case 5: return 'Over Voltage';
      case 6: return 'Unspecified Failure';
      case 7: return 'Cold';
      default: return 'Unknown';
    }
  }
  
  // Helper: Convert SIM state code to string
  String _getSimStateString(int simState) {
    switch (simState) {
      case 0: return 'Unknown';
      case 1: return 'Absent';
      case 2: return 'Pin Required';
      case 3: return 'Puk Required';
      case 4: return 'Locked';
      case 5: return 'Ready';
      default: return 'Unknown';
    }
  }
}