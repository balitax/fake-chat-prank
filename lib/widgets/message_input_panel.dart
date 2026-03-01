import 'package:flutter/material.dart';
import '../models/models.dart';

class MessageInputPanel extends StatefulWidget {
  final Function(String text, MessageSender sender) onSendMessage;
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
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSendMessage(text, _currentSender);
    _controller.clear();
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
                        ? Color(
                            widget.groupMembers
                                .firstWhere(
                                  (m) => m.id == widget.selectedMemberId,
                                )
                                .colorValue,
                          )
                        : Colors.grey,
                    child: Text(
                      widget.selectedMemberId != null
                          ? widget.groupMembers
                                .firstWhere(
                                  (m) => m.id == widget.selectedMemberId,
                                )
                                .name[0]
                                .toUpperCase()
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
                    onTap: widget.enabled
                        ? (_hasText ? _sendMessage : null)
                        : null,
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
