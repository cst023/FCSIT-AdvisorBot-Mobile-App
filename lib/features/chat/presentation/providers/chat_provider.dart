import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/chat_api_service.dart';

enum BackendStatus { checking, online, offline }

class ChatProvider extends ChangeNotifier {
  final ChatApiService _apiService = ChatApiService();
  final _uuid = const Uuid();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  BackendStatus _backendStatus = BackendStatus.checking;

  // ---- Persistence ----

  // Key used to store the message list and chat memory in SharedPreferences.
  static const _storageKey = 'fcsit_advisorbot_messages';


  // Maximum number of messages to persist locally.
  // Older messages beyond this limit are dropped to keep storage lean.
  static const _maxPersistedMessages = 200;

  // ---- Periodic Health Check ----

  static const _onlineInterval = Duration(seconds: 30);
  static const _offlineInterval = Duration(seconds: 10);
  Timer? _healthTimer;

  // ---- Public Getters ----

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  BackendStatus get backendStatus => _backendStatus;

  // ---- Initialisation ----

  ChatProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadMessages();          // Restore persisted messages first ...
    await _checkBackendHealth(showCheckingState: true);
    _scheduleNextCheck();
  }

  // ---- Persistence: Load ----

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);

      if (stored != null && stored.isNotEmpty) {
        final loaded = ChatMessage.decodeList(stored)
            // Drop error messages from previous sessions — they are no longer
            // relevant and would confuse the user on a fresh start.
            .where((m) => m.status != MessageStatus.error)
            .toList();

        _messages.addAll(loaded);
        notifyListeners();
      } else {
        // No saved history — show the welcome message for new users.
        _addWelcomeMessage();
      }
    } catch (_) {
      // If deserialisation fails for any reason (e.g. schema changed after
      // an app update), fall back gracefully to the welcome message.
      _messages.clear();
      _addWelcomeMessage();
    }
  }

  // ---- Persistence: Save ----

  // Called after every state change that modifies _messages.
  // Runs async in the background — UI is never blocked waiting for a disk write.
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Keep only the most recent N messages to cap storage usage.
      // If the list is within the limit this is a no-op slice.
      final toSave = _messages.length > _maxPersistedMessages
          ? _messages.sublist(_messages.length - _maxPersistedMessages)
          : _messages;

      await prefs.setString(_storageKey, ChatMessage.encodeList(toSave));
    } catch (_) {
      // Save failures are silently swallowed — a failed persist is not
      // worth crashing or alarming the user over.
    }
  }

  // ---- Health Check ----

  Future<void> _checkBackendHealth({bool showCheckingState = false}) async {
    if (showCheckingState) {
      _backendStatus = BackendStatus.checking;
      notifyListeners();
    }

    final isOnline = await _apiService.checkHealth();
    final newStatus = isOnline ? BackendStatus.online : BackendStatus.offline;

    if (newStatus != _backendStatus) {
      _backendStatus = newStatus;
      notifyListeners();
    }
  }

  void _scheduleNextCheck() {
    _healthTimer?.cancel();

    final interval = _backendStatus == BackendStatus.offline
        ? _offlineInterval
        : _onlineInterval;

    _healthTimer = Timer(interval, () async {
      if (!_isLoading) {
        await _checkBackendHealth();
      }
      _scheduleNextCheck();
    });
  }

  // ---- Welcome Message ----

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      text: "Hello! 👋 I'm **AdvisorBot**, your FCSIT academic advising assistant.\n\n"
            "You can ask me about:\n"
            "- Programme structure\n"
            "- Course requirements & prerequisites\n"
            "- Grading system & academic policies\n"
            "- Faculty information\n"
            "- GPA / CGPA calculation\n\n"
            "To help me give you the most accurate info, please ensure your questions are:\n"
            "- Clear and specific\n"
            "- Concise (avoid unnecessary details)\n"
            "- Self-contained (include all relevant info in one message, avoid vague follow ups)\n\n"
            "How can I help you today?",
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    ));
  }

  // ---- Core Actions ----

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _messages.add(ChatMessage(
      id: _uuid.v4(),
      text: trimmed,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
    ));

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.sendMessage(trimmed);

      _messages.add(ChatMessage(
        id: _uuid.v4(),
        text: response.answer,
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
        responseTimeSeconds: response.responseTimeSeconds,
      ));

      if (_backendStatus != BackendStatus.online) {
        _backendStatus = BackendStatus.online;
      }

    } on ChatApiException catch (e) {
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        text: _friendlyError(e),
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      ));

      if (e.type == ChatApiExceptionType.network ||
          e.type == ChatApiExceptionType.timeout) {
        _backendStatus = BackendStatus.offline;
      }

    } catch (_) {
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        text: '⚠️ Something unexpected happened. Please try again.',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
      // Persist after every completed exchange (user + bot message pair).
      // Called in finally so it always runs, even after error messages.
      _saveMessages();
    }
  }

  Future<void> retryConnection() async {
    await _checkBackendHealth(showCheckingState: true);
    _scheduleNextCheck();
  }

  // clearChat wipes both in-memory messages and the persisted copy.
  void clearChat() {
    _messages.clear(); 
    _addWelcomeMessage();
    notifyListeners();
    _saveMessages(); 
  }

  // ---- Cleanup ----

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  // ---- Helpers ----

  String _friendlyError(ChatApiException e) {
    switch (e.type) {
      case ChatApiExceptionType.network:
        return '⚠️ **Unable to connect.** Please make sure the server is '
               'running and your device is on the same network.';
      case ChatApiExceptionType.timeout:
        return '⏱️ **The request timed out.** The server might be busy — '
               'please try again in a moment.';
      case ChatApiExceptionType.server:
        return '🔧 **Server error.** Something went wrong on the backend. '
               'Please try again.';
      case ChatApiExceptionType.parse:
        return '⚠️ **Unexpected response.** Please try again.';
    }
  }
}
