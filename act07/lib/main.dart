import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fading Text Animation',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomePage({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Color _textColor = Colors.black;

  // Keys to access each page's toggleAnimation() methods.
  final GlobalKey<_FadingTextPageState> _page1Key = GlobalKey();
  final GlobalKey<_SecondFadingPageState> _page2Key = GlobalKey();

  // Shows a simple color picker dialog.
  void _pickColor() async {
    final Color? selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _colorOption(Colors.black),
              _colorOption(Colors.red),
              _colorOption(Colors.green),
              _colorOption(Colors.blue),
              _colorOption(Colors.orange),
              _colorOption(Colors.purple),
            ],
          ),
        );
      },
    );
    if (selectedColor != null) {
      setState(() {
        _textColor = selectedColor;
      });
    }
  }

  Widget _colorOption(Color color) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Tells the current page to start/stop its fade animation.
  void _toggleAnimationOnCurrentPage() {
    if (_currentPage == 0) {
      _page1Key.currentState?.toggleAnimation();
    } else {
      _page2Key.currentState?.toggleAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Text Animation'),
        actions: [
          // Day/Night mode toggle
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            ),
            onPressed: widget.onToggleTheme,
          ),
          // Color picker icon
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _pickColor,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          // Page 1 with slower fade
          FadingTextPage(key: _page1Key, textColor: _textColor),
          // Page 2 with faster fade
          SecondFadingPage(key: _page2Key, textColor: _textColor),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAnimationOnCurrentPage,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}

class FadingTextPage extends StatefulWidget {
  final Color textColor;

  const FadingTextPage({
    Key? key,
    required this.textColor,
  }) : super(key: key);

  @override
  State<FadingTextPage> createState() => _FadingTextPageState();
}

class _FadingTextPageState extends State<FadingTextPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _isAnimating = false;
  bool _showFrame = false;

  @override
  void initState() {
    super.initState();
    // Slower fade on page 1 (2 seconds).
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Start/stop repeated fade in/out
  void toggleAnimation() {
    if (_isAnimating) {
      _controller.stop();
      _isAnimating = false;
    } else {
      // Repeats the fade in/out indefinitely
      _controller.repeat(reverse: true);
      _isAnimating = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            // Fade transition for the text
            FadeTransition(
              opacity: _opacityAnimation,
              child: Text(
                'Hello, Flutter!',
                style: TextStyle(
                  fontSize: 24,
                  color: widget.textColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Image with rounded corners from assets
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: _showFrame
                    ? Border.all(color: Colors.grey, width: 2.0)
                    : null,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  'assets/image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Switch to toggle the frame around the image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Show Frame'),
                Switch(
                  value: _showFrame,
                  onChanged: (bool value) {
                    setState(() {
                      _showFrame = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SecondFadingPage extends StatefulWidget {
  final Color textColor;

  const SecondFadingPage({
    Key? key,
    required this.textColor,
  }) : super(key: key);

  @override
  State<SecondFadingPage> createState() => _SecondFadingPageState();
}

class _SecondFadingPageState extends State<SecondFadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    // Faster fade on page 2 (700 ms).
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Start/stop repeated fade in/out
  void toggleAnimation() {
    if (_isAnimating) {
      _controller.stop();
      _isAnimating = false;
    } else {
      _controller.repeat(reverse: true);
      _isAnimating = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Text(
          'Welcome to Second Screen!',dd
          style: TextStyle(fontSize: 24, color: widget.textColor),
        ),
      ),
    );
  }
}
