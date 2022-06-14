import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_in_whatsapp/call_log_bloc.dart';
import 'package:open_in_whatsapp/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

// TODO release
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  final prefs = await SharedPreferences.getInstance();
  GetIt.I.registerSingleton<SharedPreferences>(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open in whatsapp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: lightColorScheme,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: lightColorScheme.background,
        cardColor: lightColorScheme.surface,
        appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColorScheme.secondary,
          foregroundColor: lightColorScheme.onSecondary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: lightColorScheme.primary,
            onPrimary: lightColorScheme.onPrimary,
            surfaceTintColor: lightColorScheme.surfaceTint,
            onSurface: lightColorScheme.onSurface,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: darkColorScheme,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: darkColorScheme.background,
        cardColor: darkColorScheme.surface,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColorScheme.secondary,
          foregroundColor: darkColorScheme.onSecondary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: darkColorScheme.secondary,
            onPrimary: darkColorScheme.onSecondary,
            surfaceTintColor: darkColorScheme.surfaceTint,
            onSurface: darkColorScheme.onSurface,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      home: BlocProvider(
        create: (context) => CallLogCubit(GetIt.I<SharedPreferences>()),
        child: const MyHomePage(),
      ),
    );
  }
}
