import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/user_state_provider.dart';
import '../../core/theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {}); // Rebuild to update button state
    });
  }

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '👋',
      title: 'Merhaba!',
      subtitle: 'Sana nasıl hitap edelim?',
      description:
          'Auro, senin kişisel asistanın. Daha samimi olabilmemiz için ismini öğrenebilir miyim?',
      color: AppTheme.accentPurple,
      isInputPage: true,
    ),
    OnboardingPage(
      emoji: '🎨',
      title: 'Auro\'ya Hoş Geldin',
      subtitle: 'Ruhunun Rengi Ne?',
      description:
          'Duygularını sayılarla değil, renklerle ve sanatla ifade et. '
          'Her gün içindeki rengi keşfet ve bir sanat eserine dönüştür.',
      color: const Color(0xFF6C5CE7),
    ),
    OnboardingPage(
      emoji: '✨',
      title: 'Duygunu Seç',
      subtitle: 'Kelimeler Renklere Dönüşür',
      description:
          'Nasıl hissettiğini seç ve izle - uygulama senin için '
          'benzersiz bir aura yaratacak. Her duygu, kendi rengini taşır.',
      color: const Color(0xFF00CEC9),
    ),
    OnboardingPage(
      emoji: '🧘',
      title: 'Rahatlama Zamanı',
      subtitle: 'Nefes Al, Bırak',
      description:
          'Stresli anlarında nefes egzersizleri ve rahatlatıcı '
          'mesajlarla kendine gel. Auro, senin için her zaman burada.',
      color: const Color(0xFFFF7675),
    ),
    OnboardingPage(
      emoji: '📊',
      title: 'Kendini Tanı',
      subtitle: 'Zamanla Keşfet',
      description:
          'Geçmiş auralarına bak, duygu trendlerini gör. '
          'Kendini daha iyi tanımak için verilerini keşfet.',
      color: const Color(0xFFFDCB6E),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ismini bizimle paylaş :)')),
      );
      return;
    }

    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // Save name using repository via ProviderContainer or simple hive call
      // Since specific repo provider isn't available in StatefulWidget without consumer
      // We will access it via context if wrapped, or manually for now.
      // Better approach: Make OnboardingScreen a ConsumerStatefulWidget
    }

    HapticFeedback.mediumImpact();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pages[_currentPage].color.withValues(alpha: 0.3),
                  Colors.black,
                ],
              ),
            ),
          ),

          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              HapticFeedback.selectionClick();
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                'Atla',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage].color
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),

                // Next/Start Button
                GestureDetector(
                  onTap: _nextPage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == _pages.length - 1 ? 200 : 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _pages[_currentPage].color,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentPage].color.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _currentPage == _pages.length - 1
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Başla',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            )
                          : const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji with glow
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Text(page.emoji, style: const TextStyle(fontSize: 100)),
              );
            },
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: page.color, blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: page.color,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Description or Input
          if (page.isInputPage) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'İsminiz...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ] else
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final bool isInputPage;

  OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    this.isInputPage = false,
  });
}
