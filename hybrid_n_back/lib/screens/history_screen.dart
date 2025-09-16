import 'package:flutter/material.dart';
import 'package:hybrid_n_back/models/game_session.dart';
import 'package:hybrid_n_back/screens/summary_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  // Mock data for history
  final List<GameSession> _sessions = [
    GameSession(
      nLevel: 2,
      score: 120,
      maxNReached: 3,
      correctResponses: 18,
      falseAlarms: 2,
      totalTrials: 20,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GameSession(
      nLevel: 3,
      score: 150,
      maxNReached: 3,
      correctResponses: 22,
      falseAlarms: 3,
      totalTrials: 25,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GameSession(
      nLevel: 2,
      score: 80,
      maxNReached: 2,
      correctResponses: 12,
      falseAlarms: 4,
      totalTrials: 16,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    GameSession(
      nLevel: 4,
      score: 220,
      maxNReached: 4,
      correctResponses: 28,
      falseAlarms: 2,
      totalTrials: 30,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
    GameSession(
      nLevel: 3,
      score: 160,
      maxNReached: 3,
      correctResponses: 24,
      falseAlarms: 1,
      totalTrials: 25,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History & Progress'),
      ),
      body: Column(
        children: [
          // Progress Chart (simplified - just showing bars)
          Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Max N-Level Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _sessions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final session = entry.value;
                      final maxN = session.maxNReached;
                      
                      // Calculate height percentage (assuming max N could be 6)
                      final double heightPercent = maxN / 6;
                      
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('$maxN'),
                              const SizedBox(height: 4),
                              Container(
                                height: 120 * heightPercent,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Day ${_sessions.length - index}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Session History List
          Expanded(
            child: ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final dateFormat = DateFormat('MMM dd, yyyy - h:mm a');
                
                return ListTile(
                  title: Text(
                    'N-Level ${session.nLevel} Session',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${dateFormat.format(session.timestamp)}\n'
                    'Score: ${session.score} | Accuracy: ${session.accuracy.toStringAsFixed(1)}%',
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SummaryScreen(
                          session: session,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}