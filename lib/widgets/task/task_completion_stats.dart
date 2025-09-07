import 'package:flutter/material.dart';

class TaskCompletionStats extends StatelessWidget {
  final Map<String, int> stats;

  const TaskCompletionStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final inProgress = stats['inProgress'] ?? 0;
    final pending = stats['pending'] ?? 0;
    final blocked = stats['blocked'] ?? 0;

    final completionRate = total > 0 ? (completed / total * 100).toInt() : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '完成统计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCompletionRateColor(completionRate)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getCompletionRateColor(completionRate)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '$completionRate%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getCompletionRateColor(completionRate),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total > 0) ...[
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completed / total,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCompletionRateColor(completionRate),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('已完成', completed, Colors.green),
                _buildStatItem('进行中', inProgress, Colors.blue),
                _buildStatItem('待处理', pending, Colors.orange),
                _buildStatItem('阻塞', blocked, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getCompletionRateColor(int rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.blue;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}
