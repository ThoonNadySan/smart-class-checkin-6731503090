import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<_HistoryData> _historyFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyFuture = _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<_HistoryData> _loadHistory() async {
    final checkins = await StorageService.getCheckins();
    final checkouts = await StorageService.getCheckouts();
    return _HistoryData(checkins: checkins, checkouts: checkouts);
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _loadHistory();
    });
  }

  String _formatDate(dynamic raw) {
    if (raw is! String) return 'Unknown time';
    final parsed = DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) return 'Unknown time';

    final dd = parsed.day.toString().padLeft(2, '0');
    final mm = parsed.month.toString().padLeft(2, '0');
    final yyyy = parsed.year.toString();
    final hh = parsed.hour.toString().padLeft(2, '0');
    final min = parsed.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy  $hh:$min';
  }

  Future<void> _clearAll() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all records?'),
        content: const Text(
          'This will remove all check-in and finish-class entries from local storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      await StorageService.clearAllData();
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All records cleared.')));
      }
    }
  }

  Widget _buildEntryCard({
    required Map<String, dynamic> item,
    required bool isCheckin,
  }) {
    final accent = isCheckin
        ? const Color(0xFF005B9A)
        : const Color(0xFF1F7A4A);
    final title = isCheckin ? 'Class Check-in' : 'Finish Class';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCheckin
                        ? Icons.login_rounded
                        : Icons.check_circle_rounded,
                    color: accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  _formatDate(item['timestamp']),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('QR: ${item['qrCodeData'] ?? '-'}'),
            const SizedBox(height: 6),
            Text(
              'Lat: ${item['gpsLatitude']?.toString() ?? '-'}   Lng: ${item['gpsLongitude']?.toString() ?? '-'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            if (isCheckin) ...[
              Text('Previous: ${item['previousTopic'] ?? '-'}'),
              Text('Expected: ${item['expectedTopic'] ?? '-'}'),
              Text('Mood: ${item['mood']?.toString() ?? '-'} / 5'),
            ] else ...[
              Text('Learned: ${item['learnedToday'] ?? '-'}'),
              Text('Feedback: ${item['feedback'] ?? '-'}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, bool isCheckin) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No records yet.\nSubmit your first activity from the home screen.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, index) =>
          _buildEntryCard(item: items[index], isCheckin: isCheckin),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: const Color(0xFF0B3D91),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear All',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Check-ins'),
            Tab(text: 'Finish Class'),
          ],
        ),
      ),
      body: FutureBuilder<_HistoryData>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Unable to load history right now.'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(snapshot.data!.checkins, true),
              _buildList(snapshot.data!.checkouts, false),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryData {
  const _HistoryData({required this.checkins, required this.checkouts});

  final List<Map<String, dynamic>> checkins;
  final List<Map<String, dynamic>> checkouts;
}
