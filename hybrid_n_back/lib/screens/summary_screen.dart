import 'package:flutter/material.dart';
import 'package:hybrid_n_back/models/game_session.dart';

class SummaryScreen extends StatelessWidget {
  final GameSession session;

  const SummaryScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Performance Summary',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Score
                    _buildSummaryRow(
                      context,
                      'Final Score',
                      '${session.score}',
                      Icons.score,
                      Theme.of(context).colorScheme.primary,
                    ),
                    const Divider(height: 32),
                    
                    // Highest N
                    _buildSummaryRow(
                      context,
                      'Highest N Reached',
                      '${session.maxNReached}',
                      Icons.trending_up,
                      Theme.of(context).colorScheme.secondary,
                    ),
                    const Divider(height: 32),
                    
                    // Accuracy
                    _buildSummaryRow(
                      context,
                      'Accuracy',
                      '${session.accuracy.toStringAsFixed(1)}%',
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                    const Divider(height: 32),
                    
                    // False Alarms
                    _buildSummaryRow(
                      context,
                      'False Alarms',
                      '${session.falseAlarms}',
                      Icons.error_outline,
                      Colors.orangeAccent,
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Back to Home button
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 32,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}