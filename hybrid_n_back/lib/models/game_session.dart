class GameSession {
  final int nLevel;
  final int score;
  final int maxNReached;
  final int correctResponses;
  final int falseAlarms;
  final int totalTrials;
  final DateTime timestamp;

  GameSession({
    required this.nLevel,
    required this.score,
    required this.maxNReached,
    required this.correctResponses,
    required this.falseAlarms,
    required this.totalTrials,
    required this.timestamp,
  });

  // Calculate accuracy as a percentage
  double get accuracy {
    if (totalTrials == 0) return 0.0;
    return (correctResponses / totalTrials) * 100;
  }

  // Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'nLevel': nLevel,
      'score': score,
      'maxNReached': maxNReached,
      'correctResponses': correctResponses,
      'falseAlarms': falseAlarms,
      'totalTrials': totalTrials,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'accuracy': accuracy,
    };
  }

  // Create from a stored map
  factory GameSession.fromMap(Map<String, dynamic> map) {
    return GameSession(
      nLevel: map['nLevel'],
      score: map['score'],
      maxNReached: map['maxNReached'],
      correctResponses: map['correctResponses'],
      falseAlarms: map['falseAlarms'],
      totalTrials: map['totalTrials'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}