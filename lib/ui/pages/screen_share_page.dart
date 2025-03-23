import 'package:device_link/ui/constants/colors.dart';
import 'package:device_link/ui/pages/common_widgets/raised_container.dart';
import 'package:device_link/web_rtc/webrtc_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class ScreenSharePage extends StatefulWidget {
  const ScreenSharePage({super.key});

  @override
  State<ScreenSharePage> createState() => _ScreenSharePageState();
}

class _ScreenSharePageState extends State<ScreenSharePage> with SingleTickerProviderStateMixin {
  RTCVideoRenderer? _renderer;
  bool _streamIsReady = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _buttonVisible = true;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.value = 0.0;
  }

  Future<void> _initializeRenderer() async {
    _renderer = RTCVideoRenderer();
    await _renderer!.initialize();

    try {
      _renderer!.srcObject = WebRtcConnection.instance.remoteStream;
      if (mounted) {
        setState(() {
          _streamIsReady = true;
        });
      }
    } catch (e) {
      print('Error setting up video renderer: $e');
    }
  }

  @override
  void dispose() {
    _renderer?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleButtonVisibility() {
    setState(() {
      _buttonVisible = !_buttonVisible;
      if (_buttonVisible) {
        _fadeController.reverse();
      } else {
        _fadeController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WebRtcConnection.instance.onScreenShareStopRemote = () {
      _stopScreenShare();
      if (mounted) {
        context.go('/home');
      }
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildMainContent(),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(FluentIcons.arrow_previous_16_filled, color: Colors.white),
                    onPressed: () {
                      _stopScreenShare();
                      WebRtcConnection.instance.sendScreenShareStopMessage(isSource: false);
                      context.go('/home');
                    },
                    tooltip: 'Zpět na domovskou obrazovku\n(Vypne sdílení obrazovky)',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMainContent() {
    if (_streamIsReady && _renderer != null) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: GestureDetector(
          onDoubleTap: () async {
            _toggleButtonVisibility();
            if (await Vibration.hasVibrator() && await Vibration.hasAmplitudeControl()) {
              Vibration.vibrate(preset: VibrationPreset.singleShortBuzz);
            }
          },
          onLongPress: () async {
            _toggleButtonVisibility();
            if (await Vibration.hasVibrator() && await Vibration.hasAmplitudeControl()) {
              Vibration.vibrate(preset: VibrationPreset.singleShortBuzz);
            }
          },
          child: RTCVideoView(
            _renderer!,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
          ),
        ),
      );
    } else {
      return const RaisedContainer(
        color: raisedColor,
        child: Center(
          child: Text(
            'Zde se objeví obrazovka sdílená z připojeného zařízení.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }
  }

  void _stopScreenShare() async {
    if (_renderer != null) {
      _renderer!.srcObject = null;
    }
  }
}