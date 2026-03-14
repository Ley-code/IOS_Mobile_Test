import 'package:flutter/material.dart';
import 'package:mobile_app/features/authentication/presentation/widgets/welcome_widget.dart';

class _SlideData {
  final String imagePath;
  final String title;
  final String description;

  const _SlideData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  int _currentIndex = 0;

  final List<_SlideData> _slides = [
    const _SlideData(
      imagePath: 'assets/images/talent-management.png',
      title: 'Discover Amazing\nTalent',
      description: 'Find new and exciting creators\nto collaborate with.',
    ),
    const _SlideData(
      imagePath: 'assets/images/deal.png',
      title: 'Collaborate and\nGrow',
      description:
          'Start your journey, build your network,\nand grow your audience together.',
    ),
  ];

  // Get the total number of slides from the list
  int get _total => _slides.length;

  @override
  Widget build(BuildContext context) {
    // 3. Get the data for the current slide
    final _SlideData currentSlide = _slides[_currentIndex];
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final accent = theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 4. Wrap WelcomeWidget in an AnimatedSwitcher
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: WelcomeWidget(
                  key: ValueKey(_currentIndex),
                  imagePath: currentSlide.imagePath,
                  title: currentSlide.title,
                  description: currentSlide.description,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Stack(
                // Use a Stack to layer the controls
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _currentIndex > 0
                          ? () {
                              if (_currentIndex > 0) {
                                setState(() {
                                  _currentIndex--;
                                });
                              }
                            }
                          : null,
                      child: SizedBox(
                        width: 80,
                        child: Center(
                          child: Text(
                            _currentIndex > 0 ? 'Previous' : '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // So Row doesn't fill stack
                      children: List.generate(
                        _total,
                        (index) => _buildDot(index),
                      ),
                    ),
                  ),

                  // --- Next button (Aligned Right) ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (_currentIndex < _total - 1) {
                          setState(() {
                            _currentIndex++;
                          });
                        } else {
                          // reached last slide — navigate to next flow
                          // Adjust the route name as needed for your app
                          Navigator.pushReplacementNamed(
                            context,
                            '/user_selection_page',
                          );
                        }
                      },
                      child: SizedBox(
                        width: 80,
                        child: Center(
                          child: Text(
                            _currentIndex < _total - 1 ? 'Next' : 'Get Started',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool active = index == _currentIndex;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final subtleText =
        theme.textTheme.bodySmall?.color ?? Colors.white.withOpacity(0.7);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      width: active ? 14 : 10,
      height: active ? 14 : 10,
      decoration: BoxDecoration(
        color: active ? accent : subtleText,
        shape: BoxShape.circle,
      ),
    );
  }
}
