import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';

class MessageInputPanel extends StatefulWidget {
  final Function(
    String text,
    MessageSender sender, {
    bool isVoiceNote,
    int? voiceDuration,
  })
  onSendMessage;
  final VoidCallback? onToggleSender;
  final MessageSender defaultSender;
  final bool isDarkMode;
  final bool enabled;

  const MessageInputPanel({
    super.key,
    required this.onSendMessage,
    required this.defaultSender,
    required this.isDarkMode,
    this.onToggleSender,
    this.enabled = true,
    this.isGroupChat = false,
    this.groupMembers = const [],
    this.onMemberSelected,
    this.selectedMemberId,
  });

  final bool isGroupChat;
  final List<GroupMemberModel> groupMembers;
  final Function(String?)? onMemberSelected;
  final String? selectedMemberId;

  @override
  State<MessageInputPanel> createState() => _MessageInputPanelState();
}

class _MessageInputPanelState extends State<MessageInputPanel> {
  final TextEditingController _controller = TextEditingController();
  late MessageSender _currentSender;
  bool _hasText = false;
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _currentSender = widget.defaultSender;
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text, _currentSender);
    _controller.clear();
  }

  void _startRecording(LongPressStartDetails details) {
    if (_hasText || !widget.enabled) return;

    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _stopRecording(LongPressEndDetails details) {
    if (!_isRecording) return;

    _recordingTimer?.cancel();
    final finalDuration = _recordingDuration;

    setState(() {
      _isRecording = false;
      _recordingDuration = 0;
    });

    // Only send if it was recorded for at least 1 second
    if (finalDuration >= 1) {
      widget.onSendMessage(
        '',
        _currentSender,
        isVoiceNote: true,
        voiceDuration: finalDuration,
      );
    }
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(1, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _toggleSender() {
    setState(() {
      _currentSender = _currentSender == MessageSender.me
          ? MessageSender.other
          : MessageSender.me;
    });
    widget.onToggleSender?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final inputBg = isDark ? const Color(0xFF2A3942) : Colors.white;
    final iconColor = isDark
        ? const Color(0xFF8696A0)
        : const Color(0xFF667781);
    final chatBg = isDark ? const Color(0xFF0B141A) : const Color(0xFFEFE7DE);

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
      color: chatBg,
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Input pill
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_isRecording)
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mic,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(_recordingDuration),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Slide to cancel',
                                style: TextStyle(
                                  color: iconColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_left,
                                color: iconColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: iconColor,
                            size: 24,
                          ),
                          onPressed: () {},
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: TextField(
                            controller: _controller,
                            enabled: widget.enabled,
                            maxLines: 6,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Message',
                              hintStyle: TextStyle(
                                color: iconColor,
                                fontSize: 17,
                              ),
                              filled: false,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 10,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 17,
                              color: isDark
                                  ? const Color(0xFFE9EDEF)
                                  : const Color(0xFF111B21),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Transform.rotate(
                                angle: 0.8,
                                child: Icon(
                                  Icons.attach_file,
                                  color: iconColor,
                                  size: 22,
                                ),
                              ),
                              onPressed: () {},
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                            if (!_hasText)
                              IconButton(
                                icon: Icon(
                                  Icons.currency_rupee,
                                  color: iconColor,
                                  size: 22,
                                ),
                                onPressed: () {},
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            if (!_hasText)
                              IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: iconColor,
                                  size: 22,
                                ),
                                onPressed: () {},
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                              ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (widget.isGroupChat && widget.groupMembers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 6),
                child: PopupMenuButton<String>(
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: widget.selectedMemberId != null
                        ? (() {
                            final member = widget.groupMembers
                                .where((m) => m.id == widget.selectedMemberId)
                                .firstOrNull;
                            return member != null
                                ? Color(member.colorValue)
                                : Colors.grey;
                          })()
                        : Colors.grey,
                    child: Text(
                      widget.selectedMemberId != null
                          ? widget.groupMembers
                                    .where(
                                      (m) => m.id == widget.selectedMemberId,
                                    )
                                    .firstOrNull
                                    ?.name[0]
                                    .toUpperCase() ??
                                '?'
                          : '?',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  onSelected: widget.onMemberSelected,
                  itemBuilder: (context) => widget.groupMembers
                      .map(
                        (m) => PopupMenuItem(
                          value: m.id,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(m.colorValue),
                              ),
                              const SizedBox(width: 8),
                              Text(m.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(width: 6),
            // Send/Mic button
            GestureDetector(
              onLongPress: _toggleSender,
              onLongPressStart: _startRecording,
              onLongPressEnd: _stopRecording,
              child: Container(
                height: 48,
                width: 48,
                margin: const EdgeInsets.only(bottom: 0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00A884),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: widget.enabled && _hasText ? _sendMessage : null,
                    child: Icon(
                      _hasText ? Icons.send : Icons.mic,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
