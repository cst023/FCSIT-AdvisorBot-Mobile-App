import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/chat/presentation/screens/chat_screen.dart';

//to redeploy flutter web app in github pages:
//run: make deploy

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  runApp(const AdvisorBotApp());
}

class AdvisorBotApp extends StatelessWidget {
  const AdvisorBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: kIsWeb ? const WebShell() : const ChatScreen(),
      ),
    );
  }
}

// ==============================
// WEB SHELL 
// ==============================
// Wraps the chat screen for web while allowing it to fill the browser.

class WebShell extends StatelessWidget {
  const WebShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAED), 
      body: const Material(
        elevation: 0,
        child: ChatScreen(),
      ),
    );
  }
}
