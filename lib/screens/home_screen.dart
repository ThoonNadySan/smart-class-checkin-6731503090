import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'checkin_screen.dart';
import 'finish_class_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = StorageService.getDashboardStats();
  }

  Future<void> _reloadStats() async {
    setState(() {
      _statsFuture = StorageService.getDashboardStats();
    });
  }

  Future<void> _goToScreen(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    await _reloadStats();
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3FAFF), Color(0xFFF7FFF7)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _reloadStats,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0B3D91), Color(0xFF1C7ED6)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C7ED6).withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Smart Class Companion',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check in quickly, reflect deeply, and keep your class activity history in one place.',
                        style: TextStyle(color: Colors.white70, height: 1.3),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, int>>(
                        future: _statsFuture,
                        builder: (context, snapshot) {
                          final data =
                              snapshot.data ??
                              {
                                'checkins': 0,
                                'checkouts': 0,
                                'totalActivities': 0,
                              };

                          return Column(
                            children: [
                              Row(
                                children: [
                                  _buildStatChip(
                                    label: 'Check-ins',
                                    value: data['checkins'] ?? 0,
                                    icon: Icons.login_rounded,
                                    color: const Color(0xFF005B9A),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildStatChip(
                                    label: 'Finished',
                                    value: data['checkouts'] ?? 0,
                                    icon: Icons.task_alt_rounded,
                                    color: const Color(0xFF2F9E44),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Total activities: ${data['totalActivities'] ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionCard(
                  title: 'Class Check-in',
                  subtitle: 'GPS + QR + expectation reflection',
                  icon: Icons.qr_code_scanner_rounded,
                  colors: const [Color(0xFF005B9A), Color(0xFF1C7ED6)],
                  onTap: () => _goToScreen(const CheckinScreen()),
                ),
                const SizedBox(height: 14),
                _buildActionCard(
                  title: 'Finish Class',
                  subtitle: 'GPS + QR + learning feedback',
                  icon: Icons.fact_check_rounded,
                  colors: const [Color(0xFF1B5E20), Color(0xFF2F9E44)],
                  onTap: () => _goToScreen(const FinishClassScreen()),
                ),
                const SizedBox(height: 14),
                _buildActionCard(
                  title: 'Attendance History',
                  subtitle: 'Review and manage all local records',
                  icon: Icons.timeline_rounded,
                  colors: const [Color(0xFFB04A00), Color(0xFFE67700)],
                  onTap: () => _goToScreen(const HistoryScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
