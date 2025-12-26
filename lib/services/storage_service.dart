import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_data.dart';

class StorageService {
  static const String _lastDataKey = 'last_device_data';
  static const String _receivedDataKey = 'received_snapshots';
  
  Future<void> saveLastData(DeviceData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDataKey, data.toMap().toString());
  }
  
  Future<DeviceData?> getLastData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_lastDataKey);
    
    if (dataString != null) {
      try {
        // Simple parsing - in real app, use proper JSON
        return DeviceData.fromMap({});
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<void> saveReceivedSnapshot(DeviceData snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> snapshots = prefs.getStringList(_receivedDataKey) ?? [];
    snapshots.add(snapshot.toMap().toString());
    await prefs.setStringList(_receivedDataKey, snapshots);
  }
  
  Future<List<DeviceData>> getReceivedSnapshots() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> snapshots = prefs.getStringList(_receivedDataKey) ?? [];
    
    return snapshots.map((str) {
      try {
        return DeviceData.fromMap({}); // Parse properly later
      } catch (e) {
        return DeviceData();
      }
    }).toList();
  }
  
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastDataKey);
    await prefs.remove(_receivedDataKey);
  }
}