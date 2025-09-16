import 'package:flutter/material.dart';
import 'package:hybrid_n_back/services/bluetooth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  bool _tactileModeEnabled = false;
  bool _isScanning = false;
  bool _isConnected = false;
  String _connectedDeviceName = '';
  
  // Game settings
  int _startingNLevel = 1;
  double _stimulusDuration = 3.0; // in seconds
  bool _soundFeedbackEnabled = true;
  
  // Mock list of BLE devices
  final List<Map<String, dynamic>> _devices = [
    {'name': 'Hybrid Button V1', 'id': '00:11:22:33:44:55'},
    {'name': 'BLE Controller', 'id': 'AA:BB:CC:DD:EE:FF'},
    {'name': 'CogniFlex Device', 'id': '12:34:56:78:90:AB'},
  ];

  @override
  void initState() {
    super.initState();
    // Check current Bluetooth connection status
    _isConnected = _bluetoothService.isConnected;
    if (_isConnected) {
      _connectedDeviceName = _bluetoothService.deviceName;
    }
    
    // Listen for Bluetooth connection status changes
    _bluetoothService.connectionStatusStream.listen((connected) {
      setState(() {
        _isConnected = connected;
        if (connected) {
          _connectedDeviceName = _bluetoothService.deviceName;
        }
      });
    });
  }

  void _startScan() {
    // In a real app, this would trigger BLE scanning
    setState(() {
      _isScanning = true;
    });
    
    // Use the BluetoothService to scan for devices
    _bluetoothService.startScan().then((_) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }
  
  void _connectToDevice(Map<String, dynamic> device) {
    // Use the BluetoothService to connect to the device
    _bluetoothService.connectToDevice(device['name'], device['id']).then((success) {
      if (success && mounted) {
        setState(() {
          _isConnected = true;
          _connectedDeviceName = device['name'];
        });
        
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device['name']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _disconnectDevice() {
    _bluetoothService.disconnect().then((_) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _connectedDeviceName = '';
        });
        
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device disconnected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }
  
  void _saveSettings() {
    // In a real app, this would save settings to persistent storage
    // For now, we'll just show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Return settings to the previous screen
    Navigator.pop(context, {
      'tactileModeEnabled': _tactileModeEnabled,
      'startingNLevel': _startingNLevel,
      'stimulusDuration': _stimulusDuration,
      'soundFeedbackEnabled': _soundFeedbackEnabled,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tactile Mode Toggle
            SwitchListTile(
              title: const Text(
                'Enable Tactile Mode',
                style: TextStyle(fontSize: 18),
              ),
              subtitle: const Text(
                'Use a physical button instead of touchscreen',
              ),
              value: _tactileModeEnabled,
              onChanged: (value) {
                setState(() {
                  _tactileModeEnabled = value;
                });
              },
              secondary: Icon(
                Icons.touch_app,
                color: _tactileModeEnabled 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey,
              ),
            ),
            
            const Divider(height: 32),
            
            // Game Settings Section
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Game Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Starting N-Level
            ListTile(
              title: const Text('Starting N-Level'),
              subtitle: Text('Current: $_startingNLevel'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _startingNLevel > 1 
                        ? () {
                            setState(() {
                              _startingNLevel--;
                            });
                          } 
                        : null,
                  ),
                  Text(
                    '$_startingNLevel',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _startingNLevel < 9 
                        ? () {
                            setState(() {
                              _startingNLevel++;
                            });
                          } 
                        : null,
                  ),
                ],
              ),
            ),
            
            // Stimulus Duration
            ListTile(
              title: const Text('Stimulus Duration'),
              subtitle: Text('${_stimulusDuration.toStringAsFixed(1)} seconds'),
              trailing: Slider(
                value: _stimulusDuration,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                label: '${_stimulusDuration.toStringAsFixed(1)}s',
                onChanged: (value) {
                  setState(() {
                    _stimulusDuration = value;
                  });
                },
              ),
            ),
            
            // Sound Feedback
            SwitchListTile(
              title: const Text('Sound Feedback'),
              subtitle: const Text('Play sounds for feedback'),
              value: _soundFeedbackEnabled,
              onChanged: (value) {
                setState(() {
                  _soundFeedbackEnabled = value;
                });
              },
            ),
            
            const Divider(height: 32),
            
            // BLE Connection Section (only shown if tactile mode is enabled)
            if (_tactileModeEnabled) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bluetooth Devices',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      icon: _isScanning 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.bluetooth_searching),
                      label: Text(_isScanning ? 'Scanning...' : 'Scan'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // BLE device list
              Expanded(
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final bool isCurrentDevice = _isConnected && _connectedDeviceName == device['name'];
                    
                    return ListTile(
                      title: Text(device['name']),
                      subtitle: Text(device['id']),
                      trailing: isCurrentDevice
                          ? IconButton(
                              icon: const Icon(
                                Icons.bluetooth_connected,
                                color: Colors.green,
                              ),
                              onPressed: _disconnectDevice,
                            )
                          : const Icon(Icons.bluetooth),
                      onTap: () => _connectToDevice(device),
                      selected: isCurrentDevice,
                    );
                  },
                ),
              ),
              
              // Connection status
              if (_isConnected)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bluetooth_connected,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Connected to $_connectedDeviceName',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}