import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/layers/background_layers.dart';
import '../widgets/fixed_stage/fixed_stage.dart';
import '../widgets/fixed_stage/components/common.dart';
import '../widgets/three_d/liquid_sphere_view.dart';
import '../widgets/hand_tracking/hand_tracker.dart';

class HeroScreen extends StatefulWidget {
  const HeroScreen({super.key});

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();
  final GlobalKey<HandTrackerState> _handTrackerKey =
      GlobalKey<HandTrackerState>();

  int _currentSlide = 0;
  double _scrollProgress = 0.0;

  // Hand tracking state
  Offset _handPosition = const Offset(-100, -100);
  bool _isPinching = false;
  double _expandFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _positionsListener.itemPositions.addListener(_onScrollChange);
  }

  void _onScrollChange() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final firstVisible = positions.first;
      final height =
          (firstVisible.itemTrailingEdge - firstVisible.itemLeadingEdge).abs();
      setState(() {
        _currentSlide = firstVisible.index;
        // Calculate progress within current item (0.0 to 1.0) with NaN safety
        _scrollProgress = height > 0
            ? (firstVisible.itemLeadingEdge.abs() / height).clamp(0.0, 1.0)
            : 0.0;
      });
    }
  }

  void _onHandUpdate(Map data) {
    setState(() {
      if (data.isEmpty) {
        _handPosition = const Offset(-100, -100);
        _isPinching = false;
      } else {
        _handPosition = Offset(data['x'].toDouble(), data['y'].toDouble());
        _isPinching = data['isPinching'];
        _expandFactor = data['expandFactor'].toDouble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // LAYER 0: Grid & Spotlight
          const IgnorePointer(child: BackgroundLayers()),

          // LAYER 0.5: 3D Liquid Sphere (controlled by hand tracking)
          LiquidSphereView(scale: _expandFactor),

          // LAYER 1: Visual Stage (Fixed background, no hit tests)
          IgnorePointer(
            child: FixedStage(
              currentSlide: _currentSlide,
              scrollProgress: _scrollProgress,
            ),
          ),

          // LAYER 2: Scrollable Track (Transparent, on top of visuals)
          Positioned.fill(
            child: ScrollablePositionedList.builder(
              itemCount: 4,
              itemScrollController: _scrollController,
              itemPositionsListener: _positionsListener,
              itemBuilder: (context, index) => SizedBox(
                height: MediaQuery.of(context).size.height * 1.5,
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // LAYER 3: Interactive Buttons (Only on Slide 0, positioned to match visual layout)
          if (_currentSlide == 0)
            Center(
              child: Transform.scale(
                scale: 1.0 - (_scrollProgress * 0.1),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9 > 1400
                      ? 1400
                      : MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(), // Push buttons to bottom
                      HeroButtons(
                        isHandControlActive:
                            _handTrackerKey.currentState?.isCameraActive ??
                            false,
                        onStartHandControl: () {
                          _handTrackerKey.currentState?.startCamera();
                        },
                        onStopHandControl: () {
                          _handTrackerKey.currentState?.stopCamera();
                        },
                      ),
                      const SizedBox(height: 40), // Match visual padding
                    ],
                  ),
                ),
              ),
            ),

          // LAYER 4: Hand Tracking & Overlays
          HandCursorOverlay(position: _handPosition, isPinching: _isPinching),

          HandTracker(key: _handTrackerKey, onHandUpdate: _onHandUpdate),
        ],
      ),
    );
  }
}
