import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'dart:html' as html;

// Import allowInterop as a top-level function to avoid shadowing issues
import 'dart:js' show allowInterop;

class HandTracker extends StatefulWidget {
  final Function(Map data) onHandUpdate;

  const HandTracker({super.key, required this.onHandUpdate});

  @override
  State<HandTracker> createState() => HandTrackerState();
}

class HandTrackerState extends State<HandTracker> {
  bool _isCameraActive = false;

  @override
  void initState() {
    super.initState();
    _setupJSCallback();
  }

  void _setupJSCallback() {
    // Definitive assignment using direct allowInterop function
    js.context['onHandUpdate'] = allowInterop((data) {
      if (data == null) {
        widget.onHandUpdate({});
      } else {
        final jsData = data as js.JsObject;
        final handData = {
          'x': jsData['x'],
          'y': jsData['y'],
          'isPinching': jsData['isPinching'],
          'expandFactor': jsData['expandFactor'],
        };
        print('[HandTracker] Received data: $handData');
        widget.onHandUpdate(handData);
      }
    });
  }

  void startCamera() {
    if (_isCameraActive) {
      print('[HandTracker] Camera already active, stopping first');
      stopCamera();
      return;
    }

    print('[HandTracker] startCamera() called');

    // Check if function is available
    if (js.context.hasProperty('initHandTracking')) {
      print('[HandTracker] initHandTracking found - calling it now');
      try {
        js.context.callMethod('initHandTracking', ['camera-preview']);
        print('[HandTracker] initHandTracking called successfully');

        // Show the preview element
        final preview = html.document.getElementById('camera-preview');
        if (preview != null) {
          preview.style.display = 'block';
          print('[HandTracker] Camera preview element shown');
          setState(() {
            _isCameraActive = true;
          });
        } else {
          print('[HandTracker] WARNING: camera-preview element not found');
        }
      } catch (e) {
        print('[HandTracker] ERROR calling initHandTracking: $e');
      }
    } else {
      print('[HandTracker] ERROR: initHandTracking not found in window object');
      // List some properties to help debug
      print(
        '[HandTracker] Window has updateSphereScale: ${js.context.hasProperty('updateSphereScale')}',
      );
      print(
        '[HandTracker] Window has initThreeScene: ${js.context.hasProperty('initThreeScene')}',
      );
    }
  }

  void stopCamera() {
    print('[HandTracker] stopCamera() called');

    // Hide the preview element
    final preview = html.document.getElementById('camera-preview');
    if (preview != null) {
      preview.style.display = 'none';
    }

    // Stop MediaPipe camera if available
    if (js.context.hasProperty('stopHandTracking')) {
      try {
        js.context.callMethod('stopHandTracking', []);
      } catch (e) {
        print('[HandTracker] Error stopping hand tracking: $e');
      }
    }

    setState(() {
      _isCameraActive = false;
    });

    // Reset hand tracking data
    widget.onHandUpdate({});
  }

  bool get isCameraActive => _isCameraActive;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class HandCursorOverlay extends StatelessWidget {
  final Offset position;
  final bool isPinching;

  const HandCursorOverlay({
    super.key,
    this.position = const Offset(-100, -100),
    this.isPinching = false,
  });

  @override
  Widget build(BuildContext context) {
    if (position.dx < 0) return const SizedBox.shrink();

    return Positioned(
      left: position.dx - 10,
      top: position.dy - 10,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          width: isPinching ? 15 : 20,
          height: isPinching ? 15 : 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8C1CF), width: 2),
            color: isPinching
                ? const Color(0xFFE8C1CF)
                : const Color(0x4DE8C1CF), // 30% opacity pink
          ),
        ),
      ),
    );
  }
}
