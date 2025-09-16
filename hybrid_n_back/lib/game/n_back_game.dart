import 'dart:async';
import 'dart:math';

import 'package:hybrid_n_back/models/game_session.dart';

// A class to hold position and letter for each stimulus
class Stimulus {
  final int position; // Grid position (0-7 for 3x3 grid with center missing)
  final String letter; // Letter shown

  Stimulus(this.position, this.letter);
}

class NBackGame {
  // Game configuration
  int _nLevel = 1; // Start with n=1 by default
  int _score = 0;
  int _maxNReached = 1;
  int _correctResponses = 0;
  int _falseAlarms = 0;
  int _totalTrials = 0;
  bool _isRunning = false;
  double _stimulusDuration = 3.0; // Stimulus duration in seconds
  
  // Stimuli history
  final List<Stimulus> _stimuliHistory = [];
  
  // Available letters
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
  
  // Grid positions (for 3x3 grid with middle missing - numbered 0 to 7)
  // 0 1 2
  // 3   4
  // 5 6 7
  final List<int> _gridPositions = [0, 1, 2, 3, 4, 5, 6, 7];
  
  // Current stimulus
  Stimulus? _currentStimulus;
  
  // Stream controllers
  final _stimulusController = StreamController<Stimulus>.broadcast();
  final _scoreController = StreamController<int>.broadcast();
  final _gameOverController = StreamController<GameSession>.broadcast();
  
  // Random generator
  final _random = Random();
  
  // Timer for stimuli presentation
  Timer? _stimulusTimer;
  
  // Getters
  Stream<Stimulus> get stimulusStream => _stimulusController.stream;
  Stream<int> get scoreStream => _scoreController.stream;
  Stream<GameSession> get gameOverStream => _gameOverController.stream;
  int get currentNLevel => _nLevel;
  int get currentScore => _score;
  bool get isRunning => _isRunning;
  Stimulus? get currentStimulus => _currentStimulus;
  
  // Start a new game
  void startGame({int startLevel = 1, double? stimulusDuration}) {
    // Reset game state
    _nLevel = startLevel;
    _maxNReached = startLevel;
    _score = 0;
    _correctResponses = 0;
    _falseAlarms = 0;
    _totalTrials = 0;
    _isRunning = true;
    
    // Set stimulus duration if provided
    if (stimulusDuration != null) {
      _stimulusDuration = stimulusDuration;
    }
    
    _stimuliHistory.clear();
    
    // Initialize with random stimuli
    for (int i = 0; i < _nLevel; i++) {
      final position = _getRandomPosition();
      final letter = _getRandomLetter();
      _stimuliHistory.add(Stimulus(position, letter));
    }
    
    // Start presenting stimuli
    _startStimulusTimer();
  }
  
  // Stop the game
  void stopGame() {
    _isRunning = false;
    _stimulusTimer?.cancel();
    
    // Create a game session summary
    final session = GameSession(
      nLevel: _nLevel,
      score: _score,
      maxNReached: _maxNReached,
      correctResponses: _correctResponses,
      falseAlarms: _falseAlarms,
      totalTrials: _totalTrials,
      timestamp: DateTime.now(),
    );
    
    // Notify listeners about game over
    _gameOverController.add(session);
  }
  
  // Present the next stimulus
  void _presentNextStimulus() {
    if (!_isRunning) return;
    
    // Decide if we'll have a position match, letter match, both, or neither
    // We'll aim for around 30% chance of each type of match
    final double rand = _random.nextDouble();
    bool positionMatch = false;
    bool letterMatch = false;
    
    if (_stimuliHistory.length >= _nLevel) {
      // Position match (30% chance)
      if (rand < 0.3) {
        positionMatch = true;
      } 
      // Letter match (another 30% chance)
      else if (rand < 0.6) {
        letterMatch = true;
      }
      // Both match (10% chance)
      else if (rand < 0.7) {
        positionMatch = true;
        letterMatch = true;
      }
    }
    
    // Generate the new stimulus
    int newPosition;
    String newLetter;
    
    // Reference stimulus (n-back)
    final nBackStimulus = _stimuliHistory.length >= _nLevel 
        ? _stimuliHistory[_stimuliHistory.length - _nLevel] 
        : null;
    
    // Determine position
    if (positionMatch && nBackStimulus != null) {
      newPosition = nBackStimulus.position;
    } else {
      newPosition = _getRandomPosition(exclude: nBackStimulus?.position);
    }
    
    // Determine letter
    if (letterMatch && nBackStimulus != null) {
      newLetter = nBackStimulus.letter;
    } else {
      newLetter = _getRandomLetter(exclude: nBackStimulus?.letter);
    }
    
    // Create and store the new stimulus
    _currentStimulus = Stimulus(newPosition, newLetter);
    _stimuliHistory.add(_currentStimulus!);
    
    // Notify listeners
    _stimulusController.add(_currentStimulus!);
  }
  
  // Start the timer for presenting stimuli
  void _startStimulusTimer() {
    // Convert duration in seconds to milliseconds
    final durationMs = (_stimulusDuration * 1000).toInt();
    
    // Present a stimulus based on the configured duration
    _stimulusTimer = Timer.periodic(Duration(milliseconds: durationMs), (timer) {
      _presentNextStimulus();
    });
    
    // Present the first stimulus immediately
    _presentNextStimulus();
  }
  
  // Handle user response for position match
  void handlePositionResponse() {
    if (!_isRunning || _stimuliHistory.length <= _nLevel) return;
    
    _totalTrials++;
    
    // Check if there was a position match
    final nBackStimulus = _stimuliHistory[_stimuliHistory.length - _nLevel - 1];
    final isMatch = _currentStimulus?.position == nBackStimulus.position;
    
    if (isMatch) {
      // Correct response
      _score += 10;
      _correctResponses++;
    } else {
      // False alarm
      _score = max(0, _score - 5);
      _falseAlarms++;
    }
    
    // Update score
    _scoreController.add(_score);
    
    // Level up if enough correct responses
    if (_correctResponses > 0 && _correctResponses % 10 == 0) {
      _nLevel++;
      _maxNReached = max(_maxNReached, _nLevel);
    }
  }
  
  // Handle user response for letter match
  void handleLetterResponse() {
    if (!_isRunning || _stimuliHistory.length <= _nLevel) return;
    
    _totalTrials++;
    
    // Check if there was a letter match
    final nBackStimulus = _stimuliHistory[_stimuliHistory.length - _nLevel - 1];
    final isMatch = _currentStimulus?.letter == nBackStimulus.letter;
    
    if (isMatch) {
      // Correct response
      _score += 10;
      _correctResponses++;
    } else {
      // False alarm
      _score = max(0, _score - 5);
      _falseAlarms++;
    }
    
    // Update score
    _scoreController.add(_score);
    
    // Level up if enough correct responses
    if (_correctResponses > 0 && _correctResponses % 10 == 0) {
      _nLevel++;
      _maxNReached = max(_maxNReached, _nLevel);
    }
  }
  
  // Handle user response for both position and letter match
  void handleBothResponse() {
    if (!_isRunning || _stimuliHistory.length <= _nLevel) return;
    
    _totalTrials++;
    
    // Check if there was both a position and letter match
    final nBackStimulus = _stimuliHistory[_stimuliHistory.length - _nLevel - 1];
    final isPositionMatch = _currentStimulus?.position == nBackStimulus.position;
    final isLetterMatch = _currentStimulus?.letter == nBackStimulus.letter;
    
    if (isPositionMatch && isLetterMatch) {
      // Correct response
      _score += 20; // Higher score for identifying both matches
      _correctResponses++;
    } else {
      // False alarm
      _score = max(0, _score - 10);
      _falseAlarms++;
    }
    
    // Update score
    _scoreController.add(_score);
    
    // Level up if enough correct responses
    if (_correctResponses > 0 && _correctResponses % 8 == 0) {
      _nLevel++;
      _maxNReached = max(_maxNReached, _nLevel);
    }
  }
  
  // Get a random position
  int _getRandomPosition({int? exclude}) {
    int position;
    do {
      position = _gridPositions[_random.nextInt(_gridPositions.length)];
    } while (position == exclude);
    return position;
  }
  
  // Get a random letter
  String _getRandomLetter({String? exclude}) {
    String letter;
    do {
      letter = _letters[_random.nextInt(_letters.length)];
    } while (letter == exclude);
    return letter;
  }
  
  // Dispose resources
  void dispose() {
    _stimulusTimer?.cancel();
    _stimulusController.close();
    _scoreController.close();
    _gameOverController.close();
  }
}