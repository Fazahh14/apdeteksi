import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Dipanggil untuk frame kamera yang sudah di-throttle.
/// [rotation] = sensorOrientation kamera, [mirrored] = true untuk kamera depan.
typedef CameraFrameCallback = void Function(
  CameraImage image,
  int rotation,
  bool mirrored,
);

/// Preview kamera full-area (cover) dengan tombol bolak-balik depan/belakang
/// dan stream frame untuk deteksi real-time.
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({
    super.key,
    required this.active,
    this.onStatusChanged,
    this.onFrame,
    this.placeholder,
    this.frameInterval = const Duration(milliseconds: 300),
  });

  final bool active;
  final ValueChanged<bool>? onStatusChanged;
  final CameraFrameCallback? onFrame;
  final Widget? placeholder;
  final Duration frameInterval;

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  CameraLensDirection _direction = CameraLensDirection.back;
  bool _busy = false;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(covariant LiveCameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      widget.active ? _start() : _stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stop();
    } else if (state == AppLifecycleState.resumed && widget.active) {
      _start();
    }
  }

  Future<void> _releaseController(CameraController? c) async {
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
    } catch (_) {}
    await c.dispose();
  }

  Future<void> _start() async {
    if (_busy) return;
    _busy = true;
    try {
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_cameras.isEmpty) throw CameraException('none', 'Tidak ada kamera');

      final desc = _cameras.firstWhere(
        (c) => c.lensDirection == _direction,
        orElse: () => _cameras.first,
      );
      _direction = desc.lensDirection;

      // Lepas controller lama dulu sebelum membuat yang baru.
      final old = _controller;
      if (mounted) setState(() => _controller = null);
      await _releaseController(old);

      final controller = CameraController(
        desc,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup:
            Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();

      if (!mounted || !widget.active) {
        await controller.dispose();
        return;
      }

      if (widget.onFrame != null) {
        final mirrored = desc.lensDirection == CameraLensDirection.front;
        await controller.startImageStream((image) {
          final now = DateTime.now();
          if (now.difference(_lastFrame) < widget.frameInterval) return;
          _lastFrame = now;
          widget.onFrame?.call(image, desc.sensorOrientation, mirrored);
        });
      }

      setState(() => _controller = controller);
      widget.onStatusChanged?.call(true);
    } catch (e, st) {
      debugPrint('LiveCameraView error ($_direction): $e\n$st');
      widget.onStatusChanged?.call(false);
    } finally {
      _busy = false;
    }
  }

  Future<void> _stop() async {
    final c = _controller;
    if (mounted) setState(() => _controller = null);
    await _releaseController(c);
    widget.onStatusChanged?.call(false);
  }

  Future<void> _flip() async {
    if (_busy) return;
    _direction = _direction == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    await _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseController(_controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (ready)
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                // previewSize landscape -> tukar untuk potret
                width: c.value.previewSize!.height,
                height: c.value.previewSize!.width,
                child: CameraPreview(c),
              ),
            ),
          )
        else
          widget.placeholder ?? const ColoredBox(color: Colors.black),
        if (_cameras.length > 1)
          Positioned(
            right: 16,
            bottom: 16,
            child: Material(
              color: Colors.black45,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _flip,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.flip_camera_android_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
      ],
    );
  }
}