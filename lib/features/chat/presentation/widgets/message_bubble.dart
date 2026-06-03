import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/chat_message.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import 'typing_indicator.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.sender == MessageSender.user;
  bool get _isError => message.status == MessageStatus.error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: _isUser ? _UserBubble(message: message) : _BotBubble(message: message, isError: _isError),
    );
  }
}

// ==============================
// USER BUBBLE
// ==============================

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Timestamp
        Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 8),
          child: Text(
            DateFormatter.formatMessageTime(message.timestamp),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ),
        // Bubble
        Flexible(
          child: GestureDetector(
            onLongPress: () => _copyToClipboard(context, message.text),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.userBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: AppColors.userBubbleText,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        // User avatar
        const SizedBox(width: 10),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ==============================
// BOT BUBBLE
// ==============================

class _BotBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isError;
  const _BotBubble({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Bot avatar
        const BotAvatar(),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "AdvisorBot" label — shown above the first bot message
              // and after any user message for context clarity
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'AdvisorBot',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isError ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ),
              // Bubble
              GestureDetector(
                onLongPress: () => _copyToClipboard(context, message.text),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isError
                        ? AppColors.errorContainer
                        : AppColors.botBubble,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isError
                          ? AppColors.error.withOpacity(0.3)
                          : AppColors.botBubbleBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // Use MarkdownBody so the bot's formatted responses
                  // (bold text, bullet points, source links) render correctly.
                  child: MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 15,
                        color: isError
                            ? AppColors.error
                            : AppColors.botBubbleText,
                        height: 1.5,
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isError
                            ? AppColors.error
                            : AppColors.botBubbleText,
                      ),
                      a: const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      listBullet: TextStyle(
                        fontSize: 15,
                        color: isError
                            ? AppColors.error
                            : AppColors.botBubbleText,
                      ),
                      blockSpacing: 8,
                    ),
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final fixedHref = _normalizeHref(href);
                        final uri = Uri.tryParse(fixedHref);

                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                  ),
                ),
              ),
              // Timestamp below the bubble
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatMessageTime(message.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                    if (message.responseTimeSeconds != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Time taken: ${message.responseTimeSeconds!.round()}s',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==============================
// HELPER
// ==============================

String _normalizeHref(String href) {
  // Fixes double-encoded percent sequences like %2520 -> %20.
  if (href.contains('%25')) {
    return href.replaceAll('%25', '%');
  }
  return href;
}

void _copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Message copied'),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      width: 160,
    ),
  );
}
