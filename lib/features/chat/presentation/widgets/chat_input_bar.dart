import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';

class ChatInputBar extends StatefulWidget {
  final bool isLoading;
  final void Function(String) onSend;

  const ChatInputBar({
    super.key,
    required this.isLoading,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
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
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- Input Row ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isLoading
                            ? 'AdvisorBot is thinking...'
                            : AppStrings.chatHint,
                        hintStyle: TextStyle(
                          color: widget.isLoading
                              ? AppColors.textHint
                              : AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                      // Allow Shift+Enter for new lines on physical keyboards,
                      // but plain Enter submits the message.
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: widget.isLoading
                        ? _LoadingButton()
                        : _SendButton(
                            enabled: _hasText,
                            onTap: _submit,
                          ),
                  ),
                ],
              ),
              // ---- Disclaimer ----
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Text(
                  'AdvisorBot can make mistakes. Please verify important info.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================
// SEND BUTTON
// ==============================

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _SendButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(11),
            child: Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 22,
              semanticLabel: AppStrings.sendButtonLabel,
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================
// LOADING BUTTON (replaces send while waiting)
// ==============================

class _LoadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}