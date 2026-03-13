import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/storage_service.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  int _currentStep = 0;

  // Step 1 — GPS
  double? _latitude;
  double? _longitude;
  bool _gettingLocation = false;
  String? _locationError;

  // Step 2 — QR
  String? _qrCodeData;

  bool get _isQrScannerSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Step 3 — Form
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() {
      _gettingLocation = true;
      _locationError = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled. Please enable GPS.';
          _gettingLocation = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permission denied.';
            _gettingLocation = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError =
              'Location permission permanently denied. Enable it in settings.';
          _gettingLocation = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _gettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Failed to get location: $e';
        _gettingLocation = false;
      });
    }
  }

  Future<void> _scanQr() async {
    String? result;
    if (_isQrScannerSupported) {
      result = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
    } else {
      result = await _promptManualQrInput();
    }
    if (result != null) {
      setState(() => _qrCodeData = result);
    }
  }

  Future<String?> _promptManualQrInput() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter QR Code Data'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Paste or type QR value',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(dialogContext, text);
                }
              },
              child: const Text('Use Value'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return value;
  }

  Future<void> _save() async {
    if (_learnedTodayController.text.trim().isEmpty ||
        _feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    await StorageService.saveCheckout(
      latitude: _latitude!,
      longitude: _longitude!,
      qrCodeData: _qrCodeData!,
      learnedToday: _learnedTodayController.text.trim(),
      feedback: _feedbackController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class completion saved!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildStepIndicator() {
    final labels = ['GPS', 'QR Code', 'Reflection'];
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDone
                          ? Colors.green
                          : isActive
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade300,
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? const Color(0xFF2E7D32) : Colors.grey,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < 2)
                Container(
                  height: 2,
                  width: 20,
                  color: isDone ? Colors.green : Colors.grey.shade300,
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGpsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capture GPS Location',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your location will be recorded to confirm you attended class.',
        ),
        const SizedBox(height: 20),
        if (_gettingLocation) const Center(child: CircularProgressIndicator()),
        if (_latitude != null && _longitude != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Location Captured',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Latitude:  ${_latitude!.toStringAsFixed(6)}'),
                Text('Longitude: ${_longitude!.toStringAsFixed(6)}'),
              ],
            ),
          ),
        if (_locationError != null) ...[
          const SizedBox(height: 8),
          Text(_locationError!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _gettingLocation ? null : _getLocation,
          icon: const Icon(Icons.my_location),
          label: Text(_latitude == null ? 'Get Location' : 'Refresh Location'),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _latitude != null
                ? () => setState(() => _currentStep = 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Next', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildQrStep() {
    final instructionText = _isQrScannerSupported
        ? 'Scan the instructor\'s QR code to confirm class completion.'
        : 'Camera QR scanning is not supported on this platform. Enter your QR value manually.';

    final actionLabel = _isQrScannerSupported
        ? (_qrCodeData == null ? 'Scan QR Code' : 'Rescan QR Code')
        : (_qrCodeData == null ? 'Enter QR Value' : 'Edit QR Value');

    final actionIcon = _isQrScannerSupported
        ? Icons.qr_code_scanner
        : Icons.keyboard_alt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scan Class QR Code',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(instructionText),
        const SizedBox(height: 20),
        if (!_isQrScannerSupported)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use manual QR input on Windows desktop. Web and mobile support camera scanning.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        if (!_isQrScannerSupported) const SizedBox(height: 14),
        if (_qrCodeData != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'QR Code Scanned',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Data: $_qrCodeData',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _scanQr,
          icon: Icon(actionIcon),
          label: Text(actionLabel),
        ),
        if (_isQrScannerSupported)
          TextButton.icon(
            onPressed: () async {
              final result = await _promptManualQrInput();
              if (result != null) {
                setState(() => _qrCodeData = result);
              }
            },
            icon: const Icon(Icons.edit_note),
            label: const Text('Enter QR Value Manually Instead'),
          ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _qrCodeData != null
                    ? () => setState(() => _currentStep = 2)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Next', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Reflection',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'What did you learn today?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _learnedTodayController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Summarise what you learned in this class...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Feedback about this class / instructor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _feedbackController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Share your feedback about the class or instructor...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save & Finish',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish Class'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 28),
            if (_currentStep == 0) _buildGpsStep(),
            if (_currentStep == 1) _buildQrStep(),
            if (_currentStep == 2) _buildFormStep(),
          ],
        ),
      ),
    );
  }
}
