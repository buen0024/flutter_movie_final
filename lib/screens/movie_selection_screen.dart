import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../constants/spacing.dart';
import '../constants/custom_app_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});

  @override
  _MovieSelectionScreenState createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  String? _deviceId;
  String? _sessionId;
  List<Map<String, dynamic>> _movies = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadDeviceAndSessionId();
  }

  Future<void> _loadDeviceAndSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString('device_id');
      _sessionId = prefs.getString('session_id');

      if (_deviceId == null || _sessionId == null) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      _fetchMovies();
    } catch (e) {
      _showErrorDialog(
          'An error occurred while loading session details. Please try again.');
      if (kDebugMode) {
        print('Error loading session details: $e');
      }
    }
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
    });

    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      _showErrorDialog('API key is missing. Please check your configuration.');
      return;
    }

    final url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=en-US&page=$_currentPage';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        setState(() {
          _movies
              .addAll(results.map((movie) => Map<String, dynamic>.from(movie)));
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Failed to fetch movies. Please try again.');
      }
    } catch (e) {
      _showErrorDialog(
          'An error occurred while fetching movies. Please check your network connection and try again.');
      if (kDebugMode) {
        print('Error fetching movies: $e');
      }
    }
  }

  Future<void> _voteMovie(String vote) async {
    if (_currentIndex >= _movies.length) return;

    final movie = _movies[_currentIndex];
    final movieId = movie['id'];

    if (_sessionId == null || movieId == null) {
      _showErrorDialog('Session ID or Movie ID is missing.');
      return;
    }

    final url =
        'https://movie-night-api.onrender.com/vote-movie?session_id=$_sessionId&movie_id=$movieId&vote=$vote';

    if (kDebugMode) {
      print('Vote API URL: $url');
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['match'] == true) {
          final matchedTitle = movie['title'] ?? 'No Title';
          _showMatchDialog(movieId, matchedTitle);
        } else {
          setState(() {
            _currentIndex++;
            if (_currentIndex >= _movies.length) {
              _currentPage++;
              _fetchMovies();
            }
          });
        }
      } else {
        _showErrorDialog('Failed to vote. Please try again.');
      }
    } catch (e) {
      _showErrorDialog(
          'An error occurred while voting. Please check your network connection and try again.');
      if (kDebugMode) {
        print('Error voting movie: $e');
      }
    }
  }

  void _showMatchDialog(int movieId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('It’s a Match!'),
        content: Text('You and your partner matched on "$title".'),
        actions: [
          TextButton(
            onPressed: () {
              _endSessionAndNavigateToWelcome();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _endSessionAndNavigateToWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _movies.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Movie Selection'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_movies.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Movie Selection'),
        body: const Center(child: Text('No movies available.')),
      );
    }

    final movie = _movies[_currentIndex];
    final imageUrl = movie['poster_path'] != null
        ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
        : 'assets/images/photo-not-found.jpg';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Movie Selection'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Dismissible(
                key: ValueKey(movie['id']),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  final vote = direction == DismissDirection.endToStart
                      ? 'false'
                      : 'true';
                  _voteMovie(vote);
                },
                background: Container(
                  //color: Colors.green,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: AppSpacing.large),
                  child:
                      const Icon(Icons.thumb_up, color: Colors.green, size: 50),
                ),
                secondaryBackground: Container(
                  //color: Colors.red,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(right: AppSpacing.large),
                  child:
                      const Icon(Icons.thumb_down, color: Colors.red, size: 50),
                ),
                child: Card(
                  elevation: 8,
                  margin: EdgeInsets.zero, // Remove extra margins
                  child: Column(
                    mainAxisSize: MainAxisSize.max, // Ensure it stretches
                    children: [
                      Expanded(
                        flex: 2,
                        child: movie['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to the default image if the network image fails
                                  return Image.asset(
                                    'assets/images/photo-not-found.jpg',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/photo-not-found.jpg',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                movie['title'] ?? 'No Title',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                'Release Date: ${movie['release_date'] ?? 'Unknown'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Vote Average: ${movie['vote_average']?.toString() ?? 'N/A'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
