import 'package:flutter/services.dart';

class PermissionService {
  static const MethodChannel _channel = MethodChannel('com.project001/permissions');
  
  Future<bool> checkLocationPermission() async {
    try {
      final result = await _channel.invokeMethod('checkLocationPermission');
      return result == true;
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> requestLocationPermission() async {
    try {
      final result = await _channel.invokeMethod('requestLocationPermission');
      return result == true;
    } on PlatformException {
      return false;
    }
  }
  Future<bool> checkActivityPermission() async {
  try {
    final result = await _channel.invokeMethod('checkActivityPermission');
    return result == true;
  } on PlatformException {
    return false;
  }
}

Future<bool> requestActivityPermission() async {
  try {
    final result = await _channel.invokeMethod('requestActivityPermission');
    return result == true;
  } on PlatformException {
    return false;
  }
}
  
  Future<bool> checkPhonePermission() async {
    try {
      final result = await _channel.invokeMethod('checkPhonePermission');
      return result == true;
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> requestPhonePermission() async {
    try {
      final result = await _channel.invokeMethod('requestPhonePermission');
      return result == true;
    } on PlatformException {
      return false;
    }
  }
}