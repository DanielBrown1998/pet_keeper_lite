import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraDialog extends StatefulWidget {
  const CameraDialog({super.key});

  static Future<File?> show(BuildContext context) async {
    return showDialog<File>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CameraDialog(),
    );
  }

  @override
  State<CameraDialog> createState() => _CameraDialogState();
}

class _CameraDialogState extends State<CameraDialog>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  String? _error;
  int _currentCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _error = 'Nenhuma câmera encontrada';
        });
        return;
      }

      await _setupCamera(_cameras![_currentCameraIndex]);
    } catch (e) {
      setState(() {
        _error = 'Erro ao inicializar câmera: $e';
      });
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao configurar câmera: $e';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isInitialized = false;
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    });

    await _setupCamera(_cameras![_currentCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.off;
        break;
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      default:
        newMode = FlashMode.auto;
    }

    try {
      await _controller!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      // Flash not supported
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final XFile image = await _controller!.takePicture();

      // Copy to app's temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${tempDir.path}/$fileName';

      final File savedFile = await File(image.path).copy(savedPath);

      if (mounted) {
        Navigator.of(context).pop(savedFile);
      }
    } catch (e) {
      setState(() {
        _isTakingPicture = false;
        _error = 'Erro ao tirar foto: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Tirar Foto',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(_getFlashIcon(), color: Colors.white),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),

            // Camera preview
            AspectRatio(aspectRatio: 3 / 4, child: _buildCameraPreview()),

            // Controls
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Switch camera button
                  IconButton(
                    icon: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _cameras != null && _cameras!.length > 1
                        ? _switchCamera
                        : null,
                  ),

                  // Capture button
                  GestureDetector(
                    onTap: _isInitialized && !_isTakingPicture
                        ? _takePicture
                        : null,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isTakingPicture ? Colors.grey : Colors.white,
                        ),
                        child: _isTakingPicture
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.teal,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Placeholder for symmetry
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initCamera,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return CameraPreview(_controller!);
  }
}
