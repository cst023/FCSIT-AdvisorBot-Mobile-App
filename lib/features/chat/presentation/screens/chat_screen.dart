import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../data/models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/backend_status_banner.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../gpa_calculator/presentation/screens/gpa_calculator_screen.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Smoothly scroll to the bottom whenever a new message is added.
  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _exitSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear chat?'),
        content: const Text(
            'This will remove all messages and chat memory, and start a new conversation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ChatProvider>().clearChat();
              _scrollToBottom(animated: false);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Backend status banner (hidden when online)
          Consumer<ChatProvider>(
            builder: (_, provider, __) => BackendStatusBanner(
              status: provider.backendStatus,
              onRetry: provider.retryConnection,
            ),
          ),

          // Search results bar (visible only when searching)
          if (_isSearching && _searchQuery.isNotEmpty)
            _SearchResultsBar(query: _searchQuery),

          // Message list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                // Filter messages if search is active
                final messages = _isSearching && _searchQuery.isNotEmpty
                    ? provider.messages
                        .where((m) => m.text
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList()
                    : provider.messages;

                // Scroll to bottom when new message arrives
                if (!_isSearching) {
                  _scrollToBottom();
                }

                return messages.isEmpty
                    ? _EmptySearchResult(query: _searchQuery)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount:
                            messages.length + (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Typing indicator as the last item while loading
                          if (index == messages.length && provider.isLoading) {
                            return const TypingIndicator();
                          }
                          return MessageBubble(message: messages[index]);
                        },
                      );
              },
            ),
          ),

          // Input bar + disclaimer
          Consumer<ChatProvider>(
            builder: (_, provider, __) => ChatInputBar(
              isLoading: provider.isLoading,
              onSend: (text) {
                provider.sendMessage(text);
                _scrollToBottom();
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    if (_isSearching) {
      // Search mode — replace title with a text field
      return AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Exit search',
          onPressed: _exitSearch,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Search messages...',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      );
    }

    // Normal mode
    return AppBar(
      backgroundColor: AppColors.surface,
      titleSpacing: 16,
      title: Row(
        children: [
          // Bot avatar in app bar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Center(
              child: Text(
                '•ᴗ•',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.chatTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              // Online/Offline status subtitle
              Consumer<ChatProvider>(
                builder: (_, provider, __) {
                  final (label, color) = switch (provider.backendStatus) {
                    BackendStatus.online => (
                        AppStrings.chatSubtitleOnline,
                        AppColors.online
                      ),
                    BackendStatus.offline => (
                        AppStrings.chatSubtitleOffline,
                        AppColors.offline
                      ),
                    BackendStatus.checking => (
                        AppStrings.chatSubtitleChecking,
                        AppColors.checking
                      ),
                  };
                  return Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Search icon
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          tooltip: 'Search messages',
          onPressed: () => setState(() => _isSearching = true),
        ),
        // Kebab menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              color: AppColors.textSecondary),
          tooltip: 'More options',
          onSelected: (value) {
            if (value == 'gpa') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const GpaCalculatorScreen(),
                ),
              );
            } else if (value == 'clear') {
              _showClearChatDialog(context);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'gpa',
              child: Row(
                children: [
                  Icon(Icons.calculate_outlined,
                      size: 20, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text(AppStrings.menuCalculateGpa),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 20, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text(AppStrings.menuClearChat),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==============================
// SEARCH RESULTS COUNTER BAR
// ==============================

class _SearchResultsBar extends StatelessWidget {
  final String query;
  const _SearchResultsBar({required this.query});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (_, provider, __) {
        final count = provider.messages
            .where(
                (m) => m.text.toLowerCase().contains(query.toLowerCase()))
            .length;
        return Container(
          width: double.infinity,
          color: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            '$count result${count == 1 ? '' : 's'} for "$query"',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

// ==============================
// EMPTY SEARCH STATE
// ==============================

class _EmptySearchResult extends StatelessWidget {
  final String query;
  const _EmptySearchResult({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'No messages found for "$query"',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}