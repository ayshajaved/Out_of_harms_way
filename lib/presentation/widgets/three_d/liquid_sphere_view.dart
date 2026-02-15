import 'dart:js' as js;
import 'package:flutter/material.dart';

class LiquidSphereView extends StatefulWidget {
  final double scale;

  const LiquidSphereView({super.key, this.scale = 1.0});

  @override
  State<LiquidSphereView> createState() => _LiquidSphereViewState();
}

class _LiquidSphereViewState extends State<LiquidSphereView> {
  @override
  void didUpdateWidget(covariant LiquidSphereView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scale != oldWidget.scale) {
      print(
        '[Liquid Sphere] Scale changed: ${oldWidget.scale} -> ${widget.scale}',
      );
      _updateJSScale();
    }
  }

  void _updateJSScale() {
    try {
      if (js.context.hasProperty('updateSphereScale')) {
        js.context.callMethod('updateSphereScale', [widget.scale]);
        print('[LiquidSphere] Called updateSphereScale(${widget.scale})');
      } else {
        print('[LiquidSphere] ERROR: updateSphereScale not found in window');
      }
    } catch (e) {
      print('[LiquidSphere] ERROR updating scale: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: double.infinity, height: double.infinity);
  }
}
