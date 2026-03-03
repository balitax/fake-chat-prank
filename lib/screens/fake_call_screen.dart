import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/models.dart';

class FakeCallScreen extends StatefulWidget {
  final ChatProfileModel profile;
  final bool isVideo;
  final bool isIncoming;

  const FakeCallScreen({
    super.key,
    required this.profile,
    required this.isVideo,
    this.isIncoming = false,
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  int _seconds = 0;
  Timer? _timer;
  bool _isAccepted = false;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showRecIndicator = true;
  Timer? _recTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.isIncoming) {
      _startCall();
    }
    if (widget.isVideo) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        _startRecBlinking();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e. Please restart the app.')),
        );
      }
    }
  }

  void _startRecBlinking() {
    _recTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() => _showRecIndicator = !_showRecIndicator);
      }
    });
  }

  void _startCall() {
    setState(() => _isAccepted = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _seconds++);
      }
    });
  }

  void _acceptCall() {
    _startCall();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (Video simulation or Profile Image blur)
          if (widget.isVideo && _isAccepted)
            const Center(
              child: Icon(Icons.person, size: 200, color: Colors.white12),
            )
          else
            _buildProfileBackground(),

          // Overlay Content
          SafeArea(
            child: Column(
              children: [
                _buildTopOverlay(),
                const SizedBox(height: 20),
                Text(
                  widget.profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isAccepted
                      ? _formatDuration(_seconds)
                      : (widget.isIncoming ? 'Incoming call' : 'Calling...'),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                if (!_isAccepted && widget.isIncoming)
                  _buildIncomingControls()
                else
                  _buildCallControls(),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Mini Camera Preview (PiP)
          if (widget.isVideo && _isCameraInitialized && _isAccepted)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: CameraPreview(_cameraController!),
              ),
            ),

          // Small Contact Avatar overlay
          if (widget.isVideo && _isAccepted)
            Positioned(top: 100, left: 20, child: _buildSmallAvatar()),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.isVideo && _isAccepted)
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _showRecIndicator ? Colors.red : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'REC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            const SizedBox.shrink(),
          if (widget.isVideo)
            Column(
              children: const [
                Icon(Icons.lock, color: Colors.white70, size: 14),
                SizedBox(height: 4),
                Text(
                  'End-to-end encrypted',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          const SizedBox(width: 40), // spacer for symmetry if needed
        ],
      ),
    );
  }

  Widget _buildSmallAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.profile.profileImagePath != null
          ? Image.file(
              File(widget.profile.profileImagePath!),
              fit: BoxFit.cover,
            )
          : Container(
              color: const Color(0xFF6B7B8D),
              child: Center(
                child: Text(
                  widget.profile.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileBackground() {
    return Opacity(
      opacity: 0.3,
      child: widget.profile.profileImagePath != null
          ? Image.file(
              File(widget.profile.profileImagePath!),
              fit: BoxFit.cover,
            )
          : Container(
              color: const Color(0xFF6B7B8D),
              child: Center(
                child: Text(
                  widget.profile.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 120),
                ),
              ),
            ),
    );
  }

  Widget _buildIncomingControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCallButton(
            icon: Icons.close,
            color: Colors.red,
            onTap: () => Navigator.pop(context),
            label: 'Decline',
          ),
          _buildCallButton(
            icon: Icons.call,
            color: Colors.green,
            onTap: _acceptCall,
            label: 'Accept',
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCallAction(Icons.volume_up, 'Speaker'),
            _buildCallAction(Icons.videocam, 'Video'),
            _buildCallAction(Icons.mic_off, 'Mute'),
          ],
        ),
        const SizedBox(height: 40),
        _buildCallButton(
          icon: Icons.call_end,
          color: Colors.red,
          onTap: () => Navigator.pop(context),
          size: 64,
        ),
      ],
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? label,
    double size = 56,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ],
    );
  }

  Widget _buildCallAction(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
