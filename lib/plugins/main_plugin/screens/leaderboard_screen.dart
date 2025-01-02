import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/providers/app_state_provider.dart';
import '../../main_plugin/functions/main_plugin_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true; // Track loading state
  List<dynamic> _leaderboard = []; // Store leaderboard data

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    final appStateProvider =
    Provider.of<AppStateProvider>(context, listen: false);

    // Fetch leaderboard data using PluginHelper
    final leaderboard = await PluginHelper.getLeaderboard(appStateProvider);

    if (leaderboard is List) {
      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : _leaderboard.isEmpty
          ? Center(
        child: Text(
          'No leaderboard data available',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final user = _leaderboard[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: index == 0 ? Colors.amber : null,
              child: index == 0
                  ? Icon(Icons.star, color: Colors.white) // Highlight 1st place
                  : Text('${index + 1}'),
            ),
            title: Row(
              children: [
                Text(
                  user['username'],
                  style: TextStyle(
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                    color: index == 0 ? Colors.amber : null,
                  ),
                ),
                if (index < 3) ...[
                  SizedBox(width: 8), // Add spacing
                  Icon(Icons.bathroom, color: Colors.grey), // Toilet icon
                ],
              ],
            ),
            trailing: Text(
              '${user['points']} pts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
