import 'package:flutter/material.dart';
import 'dart:async';
import '/screen/main_navigation.dart';

class ResepSuccessScreens extends StatefulWidget {
  final String namaResep;
  final String levelKesulitan;
  final String? gambarPath;

  const ResepSuccessScreens({
    Key? key,
    required this.namaResep,
    required this.levelKesulitan,
    this.gambarPath,
  }) : super(key: key);

  @override
  State<ResepSuccessScreens> createState() => _ResepSuccessScreenState();
}

class _ResepSuccessScreenState extends State<ResepSuccessScreens>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _slideController.forward());

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        _timer?.cancel();
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.gambarPath != null
        ? 'http://192.168.0.104/rasa-rasa/images/${widget.gambarPath}'
        : null;

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 60),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const Text(
                            '🎉 Resep Berhasil Diubah!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Resep "${widget.namaResep}" telah disimpan dengan sukses',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              if (imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, size: 40),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.restaurant_menu,
                                      color: Colors.orange.shade700, size: 30),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                widget.namaResep,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(widget.levelKesulitan),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.levelKesulitan,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Text('Kembali ke beranda dalam',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          const SizedBox(height: 8),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.orange, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '$_countdown',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SlideTransition(
                      position: _slideAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _timer?.cancel();
                            _navigateToHome();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Kembali ke Beranda Sekarang',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'sulit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
