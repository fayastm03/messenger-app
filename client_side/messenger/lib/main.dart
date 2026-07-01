import 'package:flutter/material.dart';
import 'package:messenger/features/chat/providers/chat_provider.dart';
import 'package:messenger/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:messenger/features/auth/screens/splash_screen.dart';
import 'package:messenger/features/auth/providers/user_provider.dart';

void main() {
  SocketService().connect();
  final userProvider = UserProvider();
  final chatProvider = ChatProvider();

  chatProvider.userProvider = userProvider;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: chatProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat App',
      home: SplashScreen(),
    );
  }
}
