import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/workout_lib.dart';
import 'screens/workout_vid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bnxaprvmmomzthsnbihm.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJueGFwcnZtbW9tenRoc25iaWhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU0MDg5MzcsImV4cCI6MjA1MDk4NDkzN30.LQUogdaIh3WCT_Q60Na5WWvHXcYeff0ir0qSsHifAz8', // Replace with your Supabase anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simply Active Fitness',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set initial route to HomeScreen instead of login
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/workouts': (context) => WorkoutLib(), // Linked to Workout Library
      },
      onGenerateRoute: (settings) {
        // Handle dynamic route to WorkoutVideoPage
        if (settings.name == '/workout_video') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => WorkoutVideoPage(videoPath: args['videoPath']!),
          );
        }
        return null; // Default behavior for unknown routes
      },
    );
  }
}
