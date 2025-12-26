class DeviceData {
  // Battery
  int batteryLevel;
  double batteryTemperature;
  String batteryHealth;

  // Device Info
  String deviceModel;
  String androidVersion;
  String deviceName;

  // Steps & Sensors
  int stepDetectorCount;
  bool hasStepCounter;
  bool hasStepDetector;

  // Network
  String wifiSSID;
  int wifiRSSI;
  String localIP;

  // Cellular
  String carrierName;
  int cellularSignal;
  String simState;

  // Activity
  int stepCount;
  String detectedActivity;

  DateTime timestamp;

  DeviceData({
    this.batteryLevel = 0,
    this.batteryTemperature = 0.0,
    this.batteryHealth = 'Unknown',
    this.deviceModel = 'Unknown',
    this.androidVersion = 'Unknown',
    this.deviceName = 'Unknown',
    this.wifiSSID = 'Not Connected',
    this.wifiRSSI = 0,
    this.localIP = '0.0.0.0',
    this.carrierName = 'Unknown',
    this.cellularSignal = 0,
    this.simState = 'Unknown',
    this.stepCount = 0,
    this.detectedActivity = 'Still',
    this.stepDetectorCount = 0,
    this.hasStepCounter = false,
    this.hasStepDetector = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Copy with method for partial updates
  DeviceData copyWith({
    int? batteryLevel,
    double? batteryTemperature,
    String? batteryHealth,
    String? deviceModel,
    String? androidVersion,
    String? deviceName,
    String? wifiSSID,
    int? wifiRSSI,
    String? localIP,
    String? carrierName,
    int? cellularSignal,
    String? simState,
    int? stepCount,
    String? detectedActivity,
    int? stepDetectorCount,
    bool? hasStepCounter,
    bool? hasStepDetector,
    DateTime? timestamp,
  }) {
    return DeviceData(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      batteryTemperature: batteryTemperature ?? this.batteryTemperature,
      batteryHealth: batteryHealth ?? this.batteryHealth,
      deviceModel: deviceModel ?? this.deviceModel,
      androidVersion: androidVersion ?? this.androidVersion,
      deviceName: deviceName ?? this.deviceName,
      wifiSSID: wifiSSID ?? this.wifiSSID,
      wifiRSSI: wifiRSSI ?? this.wifiRSSI,
      localIP: localIP ?? this.localIP,
      carrierName: carrierName ?? this.carrierName,
      cellularSignal: cellularSignal ?? this.cellularSignal,
      simState: simState ?? this.simState,
      stepCount: stepCount ?? this.stepCount,
      detectedActivity: detectedActivity ?? this.detectedActivity,
      stepDetectorCount: stepDetectorCount ?? this.stepDetectorCount,
      hasStepCounter: hasStepCounter ?? this.hasStepCounter,
      hasStepDetector: hasStepDetector ?? this.hasStepDetector,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Convert to map for shared_preferences - UPDATED with new fields
  Map<String, dynamic> toMap() {
    return {
      'batteryLevel': batteryLevel,
      'batteryTemperature': batteryTemperature,
      'batteryHealth': batteryHealth,
      'deviceModel': deviceModel,
      'androidVersion': androidVersion,
      'deviceName': deviceName,
      'wifiSSID': wifiSSID,
      'wifiRSSI': wifiRSSI,
      'localIP': localIP,
      'carrierName': carrierName,
      'cellularSignal': cellularSignal,
      'simState': simState,
      'stepCount': stepCount,
      'stepDetectorCount': stepDetectorCount, // ADDED
      'hasStepCounter': hasStepCounter,       // ADDED
      'hasStepDetector': hasStepDetector,     // ADDED
      'detectedActivity': detectedActivity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from map - UPDATED with new fields
  factory DeviceData.fromMap(Map<String, dynamic> map) {
    return DeviceData(
      batteryLevel: map['batteryLevel'] ?? 0,
      batteryTemperature: map['batteryTemperature']?.toDouble() ?? 0.0,
      batteryHealth: map['batteryHealth'] ?? 'Unknown',
      deviceModel: map['deviceModel'] ?? 'Unknown',
      androidVersion: map['androidVersion'] ?? 'Unknown',
      deviceName: map['deviceName'] ?? 'Unknown',
      wifiSSID: map['wifiSSID'] ?? 'Not Connected',
      wifiRSSI: map['wifiRSSI'] ?? 0,
      localIP: map['localIP'] ?? '0.0.0.0',
      carrierName: map['carrierName'] ?? 'Unknown',
      cellularSignal: map['cellularSignal'] ?? 0,
      simState: map['simState'] ?? 'Unknown',
      stepCount: map['stepCount'] ?? 0,
      stepDetectorCount: map['stepDetectorCount'] ?? 0, // ADDED
      hasStepCounter: map['hasStepCounter'] ?? false,   // ADDED
      hasStepDetector: map['hasStepDetector'] ?? false, // ADDED
      detectedActivity: map['detectedActivity'] ?? 'Still',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}