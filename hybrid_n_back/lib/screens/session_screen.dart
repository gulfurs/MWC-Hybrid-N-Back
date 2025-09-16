import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hybrid_n_back/game/n_back_game.dart';
import 'package:hybrid_n_back/models/game_session.dart';
import 'package:hybrid_n_back/screens/summary_screen.dart';

class SessionScreen extends StatefulWidget {
  final bool isTactileMode;
  final int startingNLevel;
  final double stimulusDuration;

  const SessionScreen({
    super.key,
    this.isTactileMode = false,
    this.startingNLevel = 1,
    this.stimulusDuration = 3.0,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final NBackGame _game = NBackGame();
  int _score = 0;
  int _nLevel = 1;
  String _currentLetter = '';
  int _currentPosition = -1;
  
  // Feedback indicators
  bool _showPositionFeedback = false;
  bool _showLetterFeedback = false;
  bool _showBothFeedback = false;

  @override
  void initState() {
    super.initState();
    _setupGameListeners();
    _startGame();
  }
  
  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  void _setupGameListeners() {
    // Listen for new stimuli
    _game.stimulusStream.listen((stimulus) {
      setState(() {
        _currentLetter = stimulus.letter;
        _currentPosition = stimulus.position;
      });
    });
    
    // Listen for score updates
    _game.scoreStream.listen((score) {
      setState(() {
        _score = score;
      });
    });
    
    // Listen for game over
    _game.gameOverStream.listen((session) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(session: session),
        ),
      );
    });
  }

  void _startGame() {
    _game.startGame(
      startLevel: widget.startingNLevel,
      stimulusDuration: widget.stimulusDuration,
    );
    setState(() {
      _nLevel = _game.currentNLevel;
      _score = _game.currentScore;
    });
  }

  void _onPositionResponse() {
    _game.handlePositionResponse();
    
    setState(() {
      _showPositionFeedback = true;
    });
    
    // Reset the feedback after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showPositionFeedback = false;
        });
      }
    });
  }

  void _onLetterResponse() {
    _game.handleLetterResponse();
    
    setState(() {
      _showLetterFeedback = true;
    });
    
    // Reset the feedback after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showLetterFeedback = false;
        });
      }
    });
  }
  
  void _onBothResponse() {
    _game.handleBothResponse();
    
    setState(() {
      _showBothFeedback = true;
    });
    
    // Reset the feedback after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showBothFeedback = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('N-Level: $_nLevel'),
            Text('Score: $_score'),
          ],
        ),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Column(
        children: [
          // Game grid (3x3 with middle missing)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildGrid(),
            ),
          ),
          
          // Letter display
          Container(
            margin: const EdgeInsets.all(16.0),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _currentLetter,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ),
          
          // Response buttons
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      // Position match button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onPositionResponse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _showPositionFeedback 
                                ? Theme.of(context).colorScheme.primary 
                                : null,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.grid_on),
                              SizedBox(height: 4),
                              Text('Position Match'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Letter match button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onLetterResponse,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _showLetterFeedback 
                                ? Theme.of(context).colorScheme.secondary 
                                : null,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.text_fields),
                              SizedBox(height: 4),
                              Text('Letter Match'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Both match button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onBothResponse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showBothFeedback 
                            ? Colors.purple 
                            : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Both Match'),
                    ),
                  ),
                  
                  // Stop session button
                  ElevatedButton(
                    onPressed: () {
                      _game.stopGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: const Text('Stop Session'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 9, // 3x3 grid
      itemBuilder: (context, index) {
        // Skip the middle cell (index 4)
        if (index == 4) {
          return Container(); // Empty space
        }
        
        // Convert from 0-8 index to 0-7 (skipping the middle)
        int position = index < 4 ? index : index - 1;
        
        // Check if this is the active position
        bool isActive = position == _currentPosition;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isActive 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive 
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ] 
                : null,
          ),
        );
      },
    );
  }
}