import 'package:device_pulse/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/data_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PermissionService _permissionService;
  
  @override
  void initState() {
    super.initState();
    _permissionService = PermissionService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndLoadData();
    });
  }

  Future<void> _checkPermissionsAndLoadData() async {
    // Check and request location permission for Wi-Fi SSID
    final hasLocationPermission = await _permissionService.checkLocationPermission();
    if (!hasLocationPermission) {
      final granted = await _permissionService.requestLocationPermission();
      if (!granted) {
        // Show warning but still load data (some features will be limited)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission needed for Wi-Fi information'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
    
    // Check phone permission for cellular data
    final hasPhonePermission = await _permissionService.checkPhonePermission();
    if (!hasPhonePermission) {
      final granted = await _permissionService.requestPhonePermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone permission needed for cellular information'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    
    // Check activity permission for step counting
    final hasActivityPermission = await _permissionService.checkActivityPermission();
    if (!hasActivityPermission) {
      final granted = await _permissionService.requestActivityPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity permission needed for step counting'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    
    // Load device data
    if (mounted) {
      await context.read<DeviceProvider>().initializeData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Pulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.isRefreshing ? null : provider.refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }
  
  Widget _buildBody(DeviceProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _checkPermissionsAndLoadData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Battery Section
            DataCard(
              title: 'BATTERY',
              icon: Icons.battery_full,
              iconColor: Colors.green,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueCard(
                      label: 'Level',
                      value: provider.currentData.batteryLevel.toString(),
                      unit: '%',
                      valueColor: _getBatteryColor(provider.currentData.batteryLevel),
                    ),
                    ValueCard(
                      label: 'Temperature',
                      value: provider.currentData.batteryTemperature.toStringAsFixed(1),
                      unit: '°C',
                      valueColor: _getTemperatureColor(provider.currentData.batteryTemperature),
                    ),
                    ValueCard(
                      label: 'Health',
                      value: provider.currentData.batteryHealth,
                      valueColor: _getHealthColor(provider.currentData.batteryHealth),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Battery level visual
                LinearProgressIndicator(
                  value: provider.currentData.batteryLevel / 100,
                  backgroundColor: Colors.grey[800],
                  color: _getBatteryColor(provider.currentData.batteryLevel),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Device Info Section
            DataCard(
              title: 'DEVICE INFO',
              icon: Icons.phone_android,
              iconColor: Colors.blue,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Model',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            provider.currentData.deviceModel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Android',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            provider.currentData.androidVersion,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Name',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      provider.currentData.deviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Network Section
            DataCard(
              title: 'NETWORK',
              icon: Icons.wifi,
              iconColor: Colors.orange,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wi-Fi',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            provider.currentData.wifiSSID,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ValueCard(
                      label: 'Signal',
                      value: provider.currentData.wifiRSSI.toString(),
                      unit: 'dBm',
                      valueColor: _getSignalColor(provider.currentData.wifiRSSI),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local IP',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Text(
                      provider.currentData.localIP,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Activity Section (UPDATED)
            DataCard(
              title: 'ACTIVITY',
              icon: Icons.directions_walk,
              iconColor: Colors.purple,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueCard(
                          label: 'Steps',
                          value: provider.currentData.stepCount.toString(),
                          valueColor: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        // Show step detector count if available
                        if (provider.currentData.stepDetectorCount > 0)
                          Text(
                            'Detected steps: ${provider.currentData.stepDetectorCount}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        Chip(
                          label: Text(provider.currentData.detectedActivity),
                          backgroundColor: _getActivityColor(provider.currentData.detectedActivity),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Sensor Availability Status
                Row(
                  children: [
                    // Step Counter Status
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: provider.currentData.hasStepCounter 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: provider.currentData.hasStepCounter 
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              provider.currentData.hasStepCounter 
                                  ? Icons.check_circle 
                                  : Icons.warning,
                              size: 14,
                              color: provider.currentData.hasStepCounter 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                provider.currentData.hasStepCounter 
                                    ? "Step counter" 
                                    : "No step counter",
                                style: TextStyle(
                                  color: provider.currentData.hasStepCounter 
                                      ? Colors.green 
                                      : Colors.orange,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Step Detector Status
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: provider.currentData.hasStepDetector 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: provider.currentData.hasStepDetector 
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              provider.currentData.hasStepDetector 
                                  ? Icons.check_circle 
                                  : Icons.warning,
                              size: 14,
                              color: provider.currentData.hasStepDetector 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                provider.currentData.hasStepDetector 
                                    ? "Step detector" 
                                    : "No step detector",
                                style: TextStyle(
                                  color: provider.currentData.hasStepDetector 
                                      ? Colors.green 
                                      : Colors.orange,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Last Update Time
                if (provider.currentData.stepCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Last updated: ${_formatTimeSince(provider.currentData.timestamp)}",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Cellular Section
            DataCard(
              title: 'CELLULAR',
              icon: Icons.sim_card,
              iconColor: Colors.cyan,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carrier',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          Text(
                            provider.currentData.carrierName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ValueCard(
                      label: 'Signal',
                      value: provider.currentData.cellularSignal.toString(),
                      unit: 'dBm',
                      valueColor: _getSignalColor(provider.currentData.cellularSignal),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIM State',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Chip(
                      label: Text(provider.currentData.simState),
                      backgroundColor: provider.currentData.simState == 'Ready'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Will implement later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share My Pulse'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Will implement later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('History feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View Received Data'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for color coding
  Color _getBatteryColor(int level) {
    if (level > 70) return Colors.green;
    if (level > 30) return Colors.orange;
    return Colors.red;
  }
  
  Color _getTemperatureColor(double temp) {
    if (temp < 35) return Colors.green;
    if (temp < 40) return Colors.orange;
    return Colors.red;
  }
  
  Color _getHealthColor(String health) {
    switch (health.toLowerCase()) {
      case 'good': return Colors.green;
      case 'overheat': return Colors.red;
      default: return Colors.orange;
    }
  }
  
  Color _getSignalColor(int signal) {
    if (signal > -70) return Colors.green;
    if (signal > -85) return Colors.orange;
    return Colors.red;
  }
  
  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
      case 'walking': return Colors.green.withOpacity(0.2);
      case 'moving': return Colors.blue.withOpacity(0.2);
      case 'running': return Colors.red.withOpacity(0.2);
      case 'cycling': return Colors.purple.withOpacity(0.2);
      default: return Colors.grey.withOpacity(0.2);
    }
  }
  
  // Helper method to format time since last update
  String _formatTimeSince(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}