import 'dart:async';
import 'package:device_pulse/models/device_data.dart';
import 'package:flutter/services.dart';

class DataService {
  // Platform Channels
  static const MethodChannel _deviceChannel = MethodChannel('com.project001/device');
  static const MethodChannel _batteryChannel = MethodChannel('com.project001/battery');
  static const MethodChannel _networkChannel = MethodChannel('com.project001/network');
  static const MethodChannel _sensorChannel = MethodChannel('com.project001/sensor');
  
  // Get all device data at once
  Future<Map<String, dynamic>> getAllDeviceData() async {
    try {
      final batteryData = await getBatteryData();
      final deviceInfo = await getDeviceInfo();
      final networkInfo = await getNetworkInfo();
      final sensorData = await getSensorData();
      
      return {
        ...batteryData,
        ...deviceInfo,
        ...networkInfo,
        ...sensorData,
      };
    } on PlatformException catch (e) {
      print("Failed to get device data: '${e.message}'.");
      throw Exception('Failed to get device data: ${e.message}');
    }
  }
  
  // Get battery data
  Future<Map<String, dynamic>> getBatteryData() async {
    try {
      final result = await _batteryChannel.invokeMethod('getBatteryInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Failed to get battery data: '${e.message}'.");
      // Return safe defaults
      return {
        'batteryLevel': 0,
        'batteryTemperature': 0.0,
        'batteryHealth': 'Unknown',
        'isCharging': false,
        'chargePlug': 0,
      };
    }
  }
  
  // Get device information
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _deviceChannel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Failed to get device info: '${e.message}'.");
      return {
        'deviceModel': 'Unknown',
        'androidVersion': 'Unknown',
        'deviceName': 'Unknown',
        'manufacturer': 'Unknown',
        'product': 'Unknown',
      };
    }
  }
  
  // Get network information
  Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final result = await _networkChannel.invokeMethod('getNetworkInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Failed to get network info: '${e.message}'.");
      return {
        'wifiSSID': 'Not Connected',
        'wifiRSSI': 0,
        'localIP': '0.0.0.0',
        'macAddress': 'Unknown',
        'networkType': 'Unknown',
      };
    }
  }
  
  // Get sensor data (step count, activity)
  Future<Map<String, dynamic>> getSensorData() async {
    try {
      final result = await _sensorChannel.invokeMethod('getSensorData');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Failed to get sensor data: '${e.message}'.");
      return {
        'stepCount': 0,
        'detectedActivity': 'Still',
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    }
  }
  
  // Get cellular information
  Future<Map<String, dynamic>> getCellularInfo() async {
    try {
      final result = await _deviceChannel.invokeMethod('getCellularInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Failed to get cellular info: '${e.message}'.");
      return {
        'carrierName': 'Unknown',
        'cellularSignal': 0,
        'simState': 'Unknown',
        'networkOperator': 'Unknown',
        'phoneType': 'Unknown',
      };
    }
  }
  
  // Start listening for real-time updates
  static const EventChannel _batteryEventChannel = EventChannel('com.project001/battery/events');
  
  Stream<Map<String, dynamic>> getBatteryStream() {
    return _batteryEventChannel
        .receiveBroadcastStream()
        .map((data) => Map<String, dynamic>.from(data));
  }
}