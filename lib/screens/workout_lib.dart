import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'workout_vid.dart'; // Import the video player page

class WorkoutLib extends StatefulWidget {
  const WorkoutLib({super.key});

  @override
  State<WorkoutLib> createState() => _WorkoutLib();
}

// READ FROM DATABASE
class _WorkoutLib extends State<WorkoutLib> {
  final _workoutStream = Supabase.instance.client
      .from('timer_video_metadata')
      .stream(primaryKey: ['id']); // Real-time stream from the database table

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Library'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here (e.g., navigate to a video upload page)
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _workoutStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final videos = snapshot.data;

          if (videos == null || videos.isEmpty) {
            return const Center(child: Text('No videos available'));
          }

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final videoUrl = video['file_url']; // Get the video URL from the database

              return ListTile(
                title: Text(video['file_name'] ?? 'Unnamed Video'),
                subtitle: Text('Length ${video['video_length'] ?? 'Unknown'} mins'),
                trailing: const Icon(Icons.play_circle_fill),
                onTap: () {
                  if (videoUrl != null && videoUrl.isNotEmpty) {
                    // Navigate to the video player page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutVideoPage(videoPath: videoUrl),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No URL available for this video')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
