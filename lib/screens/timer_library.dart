import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'workout_vid.dart'; // Import the video player page

class TimerLibrary extends StatefulWidget {
  final String timerType; // "HIIT" or "Strength"

  const TimerLibrary({super.key, required this.timerType});

  @override
  State<TimerLibrary> createState() => _TimerLibraryState();
}

class _TimerLibraryState extends State<TimerLibrary> {
  late final Stream<List<Map<String, dynamic>>> _timerStream;

  @override
  void initState() {
    super.initState();
    // Stream all rows from the timer_video_metadata table.
    _timerStream = Supabase.instance.client
        .from('timer_video_metadata')
        .stream(primaryKey: ['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.timerType} Timers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here (e.g., navigate to a video upload page)
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _timerStream,
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

          // Filter videos client-side based on timerType, case-insensitively.
          final filteredVideos = videos.where((video) {
            final fileName = (video['file_name'] as String?) ?? '';
            return fileName.toLowerCase().contains(widget.timerType.toLowerCase());
          }).toList();

          if (filteredVideos.isEmpty) {
            return const Center(child: Text('No videos available'));
          }

          return ListView.builder(
            itemCount: filteredVideos.length,
            itemBuilder: (context, index) {
              final video = filteredVideos[index];
              final videoUrl = video['file_url']; // Get the video URL from the database

              return ListTile(
                title: Text(video['file_name'] ?? 'Unnamed Video'),
                subtitle: Text('Length ${video['video_length'] ?? 'Unknown'} mins'),
                trailing: const Icon(Icons.play_circle_fill),
                onTap: () {
                  if (videoUrl != null && videoUrl.isNotEmpty) {
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
